#!/usr/bin/python
import hashlib

class FilterModule(object):
  def filters(self):
    return {'versioned_name': self.versioned_name}

  # Usage:
  # {{ 'foo.txt' | versioned_name('content of the file') }}
  # {{ 'foo.txt' | versioned_name(lookup('file', '/path/to/file/on/host/from/inventory')) }}
  def versioned_name(self, name, content):
    sha1_hash =  self._sha1_hash(content)
    return "{}-{}".format(name, sha1_hash)

  def _sha1_hash(self, content):
    sha1 = hashlib.sha1()
    sha1.update(content)
    return sha1.hexdigest()

