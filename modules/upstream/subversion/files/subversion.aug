(* Subversion module for Augeas
 *   Author: Marc Fournier <marc.fournier@camptocamp.com>
 *
 *   Subversion configuration are regular ini files.
 *)

module Subversion =
   autoload xfm

(************************************************************************
 * INI File settings
 *
 * subversion only supports comments starting with "#"
 *
 *************************************************************************)

let comment  = IniFile.comment "#" "#"
let sep      = IniFile.sep IniFile.sep_default IniFile.sep_default

(************************************************************************
 *                        ENTRY
 *
 * subversion doesn't support indented entries
 *
 *************************************************************************)

let entry    = IniFile.entry IniFile.entry_re sep comment

(************************************************************************
 *                         TITLE
 *
 * subversion doesn't allow anonymous entries (outside sections)
 *
 *************************************************************************)

let title    = IniFile.title IniFile.entry_re
let record   = IniFile.record title entry

(************************************************************************
 *                         LENS & FILTER
 *************************************************************************)

let lns      = IniFile.lns record comment

let filter   = incl "/etc/subversion/config"
             . incl "/etc/subversion/servers"

let xfm      = transform lns filter
