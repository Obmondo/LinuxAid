This code contains work produced by [Matthias Saou](http://matthias.saou.eu/)
with revisions made by [Thomas Downes](mailto:downes@uwm.edu) in accordance with the
Apache 2.0 license under which it was released. It is re-released under
Apache 2.0.

The modifications restructure the code
 * to allow the code to work at all in Puppet 4
 * to take advantage of features only available in Puppet 4
 * to address several issues in the original code that stem from the existence
   of a sysctl::base class while sysctl itself was a defined resource. The
   solution chosen was to make sysctl a class that uses a new defined resource
   sysctl::configuration. It is therefore intentionally not backwards-compatible
   but the changes are minor and documented in README.md.
