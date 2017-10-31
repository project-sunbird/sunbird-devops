#!/usr/bin/python
import hashlib

class FilterModule(object):
  def filters(self):
    return {'versioned_name': self.versioned_name}

  def versioned_name(self, name, file_path):
    sha1_hash =  self._sha1_hash(file_path)
    return "{}-{}".format(name, sha1_hash)

  def _sha1_hash(self, file_path):
    sha1 = hashlib.sha1()
    with open(file_path, 'rb', buffering=0) as file:
      for block in iter(lambda : file.read(128 * 1024), b''):
        sha1.update(block)
    return sha1.hexdigest()
