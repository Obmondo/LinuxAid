#!/usr/bin/env python3
"""Report hiera keys that bind to no Puppet class parameter.

Puppet's automatic parameter lookup silently drops a hiera key that matches no
class parameter -- no error, no warning, nothing in the report. This walks the
class signatures in the linuxaid modules and every YAML/EYAML file in a target
tree and reports the keys that will never be read.

Sources are given as SPEC strings so config repos can be read straight out of
git without ever touching their working trees:

    /path/to/repo                      working tree
    /path/to/repo@origin/main          tree at a git ref
    /path/to/repo@github/main:agents   subtree at a git ref
    label=/path/to/repo@origin/main    any of the above, with a report label

Example:

    bin/find-dead-hiera-keys.py \\
      --manifests ~/linuxaid-configs/linuxaid@refactor/common-param-cleanup \\
      ~/linuxaid-configs/linuxaid-config-enableit@origin/main

Exits 1 when anything is found so it can gate CI, 2 on a usage/IO error.
"""

import argparse
import difflib
import json
import os
import re
import subprocess
import sys
import threading

import yaml

DEFAULT_SCOPE = r'^(role|common|monitor)::'
DEFAULT_MANIFEST_GLOBS = ('modules/*/manifests/', 'modules/*/*/manifests/')
YAML_EXTS = ('.yaml', '.yml', '.eyaml')
EXCLUDED_DIRS = ('.git/', '.gitea/', '.github/', '/spec/', '/.fixtures/')
EXCLUDED_NAMES = ('hiera.yaml', '.yamllint', '.yamllint.yaml')
RESERVED_HIERA_KEYS = ('lookup_options', 'classes', 'alias')
REGEXY = re.compile(r'[\^\$\*\+\?\\\|\(\)\[\]]')


# --------------------------------------------------------------------------
# sources


class Tree:
    def __init__(self, spec):
        label, _, rest = spec.partition('=')
        if not rest:
            label, rest = '', spec
        repo, _, refpart = rest.partition('@')
        ref, _, sub = refpart.partition(':')
        self.repo = os.path.abspath(os.path.expanduser(repo))
        self.ref = ref or None
        self.sub = sub.strip('/')
        self.label = label or self._default_label()

    def _default_label(self):
        name = os.path.basename(self.repo)
        parts = [name]
        if self.ref:
            parts.append('@' + self.ref)
        if self.sub:
            parts.append(':' + self.sub)
        return ''.join(parts)

    def _git(self, *args):
        result = subprocess.run(
            ('git', '-C', self.repo) + args, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        if result.returncode != 0:
            raise SystemExit(f'git {" ".join(args)} failed in {self.repo}: {result.stderr.decode().strip()}')
        return result.stdout

    def list_files(self, suffixes):
        if self.ref:
            args = ['ls-tree', '-r', '-z', '--name-only', self.ref]
            if self.sub:
                args += ['--', self.sub]
            names = [n for n in self._git(*args).decode('utf-8', 'replace').split('\0') if n]
        else:
            base = os.path.join(self.repo, self.sub)
            names = []
            for dirpath, dirnames, filenames in os.walk(base):
                dirnames[:] = [d for d in dirnames if d not in ('.git', '.gitea', '.github')]
                for filename in filenames:
                    names.append(os.path.relpath(os.path.join(dirpath, filename), self.repo))
        return sorted(n for n in names if n.endswith(suffixes) and not _excluded(n))

    def read_all(self, paths):
        if not self.ref:
            contents = {}
            for path in paths:
                with open(os.path.join(self.repo, path), 'rb') as handle:
                    contents[path] = handle.read().decode('utf-8', 'replace')
            return contents
        return self._cat_file_batch(paths)

    def _cat_file_batch(self, paths):
        if not paths:
            return {}
        proc = subprocess.Popen(
            ('git', '-C', self.repo, 'cat-file', '--batch'),
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )
        request = ''.join(f'{self.ref}:{p}\n' for p in paths).encode()

        # git streams blobs back while we are still feeding it revisions, so the
        # request has to go out on its own thread or both ends block on a full pipe.
        writer = threading.Thread(target=_feed, args=(proc.stdin, request))
        writer.start()

        contents = {}
        out = proc.stdout
        for path in paths:
            header = out.readline().decode().strip()
            if header.endswith(('missing', 'ambiguous')):
                continue
            size = int(header.rsplit(' ', 1)[1])
            blob = out.read(size)
            out.read(1)
            contents[path] = blob.decode('utf-8', 'replace')
        writer.join()
        proc.stdout.close()
        proc.wait()
        return contents

    def describe(self):
        where = self.repo if not self.ref else f'{self.repo} @ {self.ref}'
        return where + (f' :{self.sub}' if self.sub else '')


def _feed(pipe, payload):
    pipe.write(payload)
    pipe.close()


def _excluded(path):
    normalised = '/' + path
    if any(part in normalised for part in EXCLUDED_DIRS):
        return True
    return os.path.basename(path) in EXCLUDED_NAMES


# --------------------------------------------------------------------------
# puppet parsing


def blank_noise(src):
    """Replace comments, string bodies and heredoc bodies with spaces.

    Blanking rather than deleting keeps every offset -- and therefore every line
    number -- identical to the original source.
    """
    out = list(src)
    index = 0
    length = len(src)
    while index < length:
        char = src[index]
        if char == '#':
            while index < length and src[index] != '\n':
                out[index] = ' '
                index += 1
        elif char == '/' and index + 1 < length and src[index + 1] == '*':
            while index < length and not (src[index] == '*' and index + 1 < length and src[index + 1] == '/'):
                if src[index] != '\n':
                    out[index] = ' '
                index += 1
            for _ in range(2):
                if index < length:
                    out[index] = ' '
                    index += 1
        elif char in '"\'':
            quote = char
            index += 1
            while index < length and src[index] != quote:
                if src[index] == '\\':
                    out[index] = ' '
                    index += 1
                if index < length:
                    if src[index] != '\n':
                        out[index] = ' '
                    index += 1
            index += 1
        elif char == '@' and index + 1 < length and src[index + 1] == '(':
            match = re.compile(r'@\(\s*"?([A-Za-z0-9_]+)"?').match(src, index)
            index = src.find('\n', index)
            if index < 0 or not match:
                break
            terminator = re.compile(r'^\s*\|?\s*-?\s*' + re.escape(match.group(1)) + r'\s*$')
            index += 1
            while index < length:
                end = src.find('\n', index)
                end = length if end < 0 else end
                if terminator.match(src[index:end]):
                    index = end
                    break
                for pos in range(index, end):
                    out[pos] = ' '
                index = end + 1
        else:
            index += 1
    return ''.join(out)


OPENERS = {'(': ')', '[': ']', '{': '}'}
CLOSERS = {')', ']', '}'}


def scan_balanced(src, start):
    """Index just past the bracket group opening at `start`."""
    depth = 0
    index = start
    while index < len(src):
        char = src[index]
        if char in OPENERS:
            depth += 1
        elif char in CLOSERS:
            depth -= 1
            if depth == 0:
                return index + 1
        index += 1
    return -1


def split_top_level(text):
    chunks = []
    depth = 0
    current = 0
    for index, char in enumerate(text):
        if char in OPENERS:
            depth += 1
        elif char in CLOSERS:
            depth -= 1
        elif char == ',' and depth == 0:
            chunks.append((current, text[current:index]))
            current = index + 1
    tail = text[current:]
    if tail.strip():
        chunks.append((current, tail))
    return chunks


PARAM_NAME_RE = re.compile(r'\$([A-Za-z_][A-Za-z0-9_]*)')


def parse_param(chunk):
    """(name, type_expr, has_default, offset_of_name) for one signature chunk."""
    depth = 0
    assign = -1
    for index, char in enumerate(chunk):
        if char in OPENERS:
            depth += 1
        elif char in CLOSERS:
            depth -= 1
        elif char == '=' and depth == 0:
            assign = index
            break
    head = chunk if assign < 0 else chunk[:assign]
    match = PARAM_NAME_RE.search(head)
    if not match:
        return None
    type_expr = head[: match.start()].strip()
    return match.group(1), type_expr, assign >= 0, match.start(1)


DECL_RE = re.compile(r'(?m)^[ \t]*(class|define)[ \t]+(?:::)?([a-z][a-zA-Z0-9_]*(?:::[a-z][a-zA-Z0-9_]*)*)')
TYPE_ALIAS_RE = re.compile(r'(?m)^[ \t]*type[ \t]+([A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*)[ \t]*=')
STRUCT_KEY_RE = re.compile(r"""(?:^|[\[{,])\s*(?:Optional\[\s*)?['"]?([A-Za-z_][A-Za-z0-9_]*)['"]?\s*\]?\s*=>""")
TYPE_REF_RE = re.compile(r'\b([A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)+)\b')


class Signature:
    __slots__ = ('name', 'kind', 'path', 'line', 'params', 'private')

    def __init__(self, name, kind, path, line):
        self.name = name
        self.kind = kind
        self.path = path
        self.line = line
        self.params = {}
        self.private = set()


class Index:
    def __init__(self):
        self.classes = {}
        self.defines = {}
        self.type_aliases = {}
        self.lookup_keys = set()
        self.param_owners = {}
        self.fqns = []

    def add(self, signature):
        target = self.classes if signature.kind == 'class' else self.defines
        target[signature.name] = signature

    def finalise(self):
        for name, signature in self.classes.items():
            for param in signature.params:
                self.param_owners.setdefault(param, []).append(name)
                self.fqns.append(f'{name}::{param}')
        self.fqns.sort()

    def struct_keys_for(self, type_expr, depth=0):
        keys = set(STRUCT_KEY_RE.findall(type_expr))
        if depth < 3:
            for ref in TYPE_REF_RE.findall(type_expr):
                alias = self.type_aliases.get(ref)
                if alias:
                    keys |= self.struct_keys_for(alias, depth + 1)
        return keys


LOOKUP_CALL_RE = re.compile(r"""(?:lookup|hiera|hiera_hash|hiera_array)\(\s*['"]([a-z][a-z0-9_]*(?:::[a-z0-9_]+)+)['"]""")


def _alias_body(raw, src, start):
    cursor = start
    while cursor < len(src) and src[cursor] in ' \t\n\r':
        cursor += 1
    open_bracket = src.find('[', cursor)
    line_end = src.find('\n', cursor)
    if open_bracket < 0 or (0 <= line_end < open_bracket):
        return raw[cursor : line_end if line_end > 0 else len(raw)]
    end = scan_balanced(src, open_bracket)
    return raw[cursor : end if end > 0 else len(raw)]


def build_index(trees):
    index = Index()
    for tree in trees:
        paths = tree.list_files(('.pp',))
        for path, raw in tree.read_all(paths).items():
            src = blank_noise(raw)
            index.lookup_keys.update(LOOKUP_CALL_RE.findall(raw))
            for match in TYPE_ALIAS_RE.finditer(src):
                index.type_aliases[match.group(1)] = _alias_body(raw, src, match.end())
            for match in DECL_RE.finditer(src):
                kind, name = match.group(1), match.group(2)
                cursor = match.end()
                while cursor < len(src) and src[cursor] in ' \t\n\r':
                    cursor += 1
                signature = Signature(name, kind, path, src.count('\n', 0, match.start()) + 1)
                if cursor < len(src) and src[cursor] == '(':
                    end = scan_balanced(src, cursor)
                    if end > 0:
                        body = raw[cursor + 1 : end - 1]
                        blanked = src[cursor + 1 : end - 1]
                        for offset, chunk in split_top_level(blanked):
                            parsed = parse_param(chunk)
                            if not parsed:
                                continue
                            param, _, has_default, name_offset = parsed
                            type_expr = body[offset : offset + name_offset]
                            signature.params[param] = {
                                'has_default': has_default,
                                'type': ' '.join(type_expr.split()).rstrip('$'),
                            }
                            if param.startswith('__'):
                                signature.private.add(param)
                index.add(signature)
    index.finalise()
    return index


# --------------------------------------------------------------------------
# hiera parsing


def summarise(node, limit=70):
    if isinstance(node, yaml.ScalarNode):
        value = node.value
        if value.startswith('ENC['):
            return 'ENC[...]'
        text = ' '.join(value.split())
    elif isinstance(node, yaml.SequenceNode):
        text = '[' + ', '.join(summarise(child, 20) for child in node.value[:4]) + (
            ', ...]' if len(node.value) > 4 else ']'
        )
    elif isinstance(node, yaml.MappingNode):
        text = '{' + ', '.join(str(key.value) for key, _ in node.value[:4]) + (
            ', ...}' if len(node.value) > 4 else '}'
        )
    else:
        text = '?'
    return text if len(text) <= limit else text[: limit - 1] + '…'


def walk_mapping(node, prefix, scope, resolver, sink):
    if not isinstance(node, yaml.MappingNode):
        return
    for key_node, value_node in node.value:
        if not isinstance(key_node, yaml.ScalarNode):
            continue
        key = str(key_node.value)
        if not prefix and key in RESERVED_HIERA_KEYS:
            if key == 'lookup_options':
                walk_mapping(value_node, '', scope, resolver, sink)
            continue
        full = f'{prefix}::{key}' if prefix else key
        if not scope.search(full):
            continue
        if REGEXY.search(full):
            continue
        verdict = resolver(full)
        if verdict['status'] == 'ok':
            continue
        if isinstance(value_node, yaml.MappingNode) and any(
            resolver(f'{full}::{child.value}')['status'] == 'ok'
            for child, _ in value_node.value
            if isinstance(child, yaml.ScalarNode)
        ):
            walk_mapping(value_node, full, scope, resolver, sink)
            continue
        sink(full, key_node.start_mark.line + 1, summarise(value_node), verdict)


# --------------------------------------------------------------------------
# resolution and suggestions


def segments(name):
    return set(name.split('::'))


def similarity(left, right):
    shared = segments(left) & segments(right)
    union = segments(left) | segments(right)
    jaccard = len(shared) / len(union) if union else 0.0
    score = 0.6 * jaccard + 0.4 * difflib.SequenceMatcher(None, left, right).ratio()
    # A class that moved namespace keeps its own name, so a matching tail is the
    # strongest rename signal there is (common::system::motd -> common::user_management::motd).
    if left.rsplit('::', 1)[-1] == right.rsplit('::', 1)[-1]:
        score += 0.25
    return score


class Resolver:
    def __init__(self, index, include_private=False):
        self.index = index
        self.include_private = include_private
        self.cache = {}

    def __call__(self, key):
        if key not in self.cache:
            self.cache[key] = self._resolve(key)
        return self.cache[key]

    def _resolve(self, key):
        if key in self.index.lookup_keys:
            return {'status': 'ok'}
        class_name, _, param = key.rpartition('::')
        if not class_name:
            return {'status': 'ok'}
        malformed = ':' in param
        signature = self.index.classes.get(class_name)
        if signature is None:
            note = ''
            if class_name in self.index.defines:
                note = 'name is a defined type, which has no automatic parameter lookup'
            return {
                'status': 'no_class',
                'class': class_name,
                'param': param,
                'note': note,
                'malformed': malformed,
            }
        if param in signature.params:
            if param.startswith('__') and not self.include_private:
                return {'status': 'ok'}
            return {'status': 'ok'}
        return {
            'status': 'no_param',
            'class': class_name,
            'param': param,
            'note': f'class declared at {signature.path}:{signature.line}',
            'malformed': malformed,
        }


def match_ignoring_style(name, candidates):
    target = name.replace('_', '').lower()
    for candidate in candidates:
        if candidate.replace('_', '').lower() == target:
            return candidate
    return None


def suggestions(verdict, index, limit=3):
    class_name, param = verdict['class'], verdict['param']
    found = []

    if verdict.get('malformed'):
        repaired = re.sub(r'(?<!:):(?!:)', '::', f'{class_name}::{param}')
        found.append((repaired, "single ':' where '::' was meant"))

    for candidate in sorted(
        index.param_owners.get(param, []), key=lambda name: -similarity(class_name, name)
    )[:2]:
        score = similarity(class_name, candidate)
        if score >= 0.30:
            found.append((f'{candidate}::{param}', 'same parameter name'))

    signature = index.classes.get(class_name)

    # The value often has not gone away, it has moved inside a structured parameter of
    # the class -- or of the nearest surviving ancestor when the leaf class is the part
    # that never existed (common::system::systemd::journal::system_max_use).
    ancestor = class_name
    while ancestor and ancestor not in index.classes:
        ancestor = ancestor.rpartition('::')[0]
    if ancestor:
        for owner, meta in index.classes[ancestor].params.items():
            nested = match_ignoring_style(param, index.struct_keys_for(meta['type']))
            if nested:
                found.append((f'{ancestor}::{owner} -> {nested}', f'nest it inside `{owner}`'))

    if signature is not None:
        for near in difflib.get_close_matches(param, list(signature.params), n=2, cutoff=0.7):
            found.append((f'{class_name}::{near}', 'similar parameter in the same class'))
    else:
        for near in difflib.get_close_matches(class_name, list(index.classes), n=3, cutoff=0.55):
            if param in index.classes[near].params:
                found.append((f'{near}::{param}', 'similar class name'))

    for near in difflib.get_close_matches(f'{class_name}::{param}', index.fqns, n=2, cutoff=0.82):
        found.append((near, 'similar key'))

    if not found and signature is None:
        module = class_name.split('::', 1)[0]
        siblings = [name for name in index.classes if name.startswith(module + '::')]
        nearest = max(siblings, key=lambda name: similarity(class_name, name), default=None)
        if nearest and similarity(class_name, nearest) >= 0.45:
            found.append((nearest, 'nearest surviving class (parameter still missing)'))

    seen, unique = set(), []
    for text, reason in found:
        if text not in seen:
            seen.add(text)
            unique.append({'suggestion': text, 'reason': reason})
    return unique[:limit]


# --------------------------------------------------------------------------
# driver


def scan(tree, index, resolver, scope, want_suggestions):
    findings = []
    paths = tree.list_files(YAML_EXTS)
    for path, raw in sorted(tree.read_all(paths).items()):
        try:
            documents = list(yaml.compose_all(raw, Loader=yaml.SafeLoader))
        except yaml.YAMLError as error:
            findings.append(
                {
                    'repo': tree.label,
                    'file': path,
                    'line': 0,
                    'key': '',
                    'value': '',
                    'status': 'unparsable',
                    'note': ' '.join(str(error).split())[:160],
                    'suggestions': [],
                }
            )
            continue
        for document in documents:
            def sink(key, line, value, verdict, _path=path):
                findings.append(
                    {
                        'repo': tree.label,
                        'file': _path,
                        'line': line,
                        'key': key,
                        'value': value,
                        'status': verdict['status'],
                        'note': verdict.get('note', ''),
                        'suggestions': suggestions(verdict, index) if want_suggestions else [],
                    }
                )

            walk_mapping(document, '', scope, resolver, sink)
    findings.sort(key=lambda item: (item['file'], item['line']))
    return findings


STATUS_LABEL = {
    'no_class': 'class does not exist',
    'no_param': 'class exists, parameter does not',
    'unparsable': 'YAML did not parse',
}


def render(results, index, stream):
    total = 0
    for tree, findings in results:
        header = f'{tree.label}  ({tree.describe()})'
        print('=' * len(header), file=stream)
        print(header, file=stream)
        print('=' * len(header), file=stream)
        if not findings:
            print('  no dead keys\n', file=stream)
            continue
        current = None
        for item in findings:
            if item['file'] != current:
                current = item['file']
                print(f'\n  {current}', file=stream)
            print(f'    {item["line"]:>5}  {item["key"]}', file=stream)
            detail = STATUS_LABEL[item['status']]
            if item['note']:
                detail += f' ({item["note"]})'
            print(f'           {detail}', file=stream)
            if item['value']:
                print(f'           value: {item["value"]}', file=stream)
            for hint in item['suggestions']:
                print(f'           did you mean: {hint["suggestion"]}  [{hint["reason"]}]', file=stream)
        total += len(findings)
        print(f'\n  {len(findings)} dead key(s)\n', file=stream)

    print('-' * 60, file=stream)
    print(f'{len(index.classes)} classes / {len(index.fqns)} parameters indexed', file=stream)
    for tree, findings in results:
        classless = sum(1 for item in findings if item['status'] == 'no_class')
        paramless = sum(1 for item in findings if item['status'] == 'no_param')
        print(
            f'{tree.label:<44} {len(findings):>4} dead  ({classless} missing class, {paramless} missing param)',
            file=stream,
        )
    print(f'{"TOTAL":<44} {total:>4} dead', file=stream)
    return total


def main(argv=None):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        '--manifests',
        action='append',
        metavar='SPEC',
        help='tree holding the puppet modules (repeatable); defaults to this script\'s repo',
    )
    parser.add_argument('--scope', default=DEFAULT_SCOPE, metavar='REGEX', help=f'default: {DEFAULT_SCOPE}')
    parser.add_argument('--no-suggest', action='store_true', help='skip the "did you mean" search')
    parser.add_argument(
        '--include-private',
        action='store_true',
        help='also report keys whose parameter starts with __ (dump_ast.rb ignores those)',
    )
    parser.add_argument('--json', metavar='FILE', help='write machine-readable findings here')
    parser.add_argument('targets', nargs='+', metavar='TARGET', help='config trees to check')
    args = parser.parse_args(argv)

    manifest_specs = args.manifests or [os.path.dirname(os.path.dirname(os.path.abspath(__file__)))]
    manifest_trees = [Tree(spec) for spec in manifest_specs]
    index = build_index(manifest_trees)
    if not index.classes:
        print('no puppet classes found -- check --manifests', file=sys.stderr)
        return 2

    scope = re.compile(args.scope)
    resolver = Resolver(index, include_private=args.include_private)
    results = [(tree, scan(tree, index, resolver, scope, not args.no_suggest)) for tree in map(Tree, args.targets)]

    total = render(results, index, sys.stdout)

    if args.json:
        with open(args.json, 'w') as handle:
            json.dump(
                {
                    'manifests': [tree.describe() for tree in manifest_trees],
                    'classes_indexed': len(index.classes),
                    'parameters_indexed': len(index.fqns),
                    'findings': [item for _, findings in results for item in findings],
                },
                handle,
                indent=2,
            )

    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main())
