# -*- coding: utf-8 -*-
#
# Copyright (c) 2020~2999 - Cologler <skyoflw@gmail.com>
# ----------
# remove empty directories
# ----------

import os
import sys
import traceback
from contextlib import suppress

assert sys.getdefaultencoding() == 'utf-8', 'encoding utf-8 is required.'

NT_CACHE_FILES = {
    'Thumbs.db'
}

def cleanup_if_all_childs_are_cachefile(root):
    names = os.listdir(root)
    if all(n in NT_CACHE_FILES for n in names):
        for name in names:
            try:
                os.remove(os.path.join(root, name))
            except FileNotFoundError:
                pass

def cleanup(root, include_self=True):
    with suppress(PermissionError): # raise when os.listdir(root)
        for name in os.listdir(root):
            item = os.path.join(root, name)
            if os.path.isdir(item):
                cleanup(item)

        cleanup_if_all_childs_are_cachefile(root)

        if include_self and not os.listdir(root):
            try:
                os.rmdir(root)
                print('removed %s' % root)
            except FileNotFoundError:
                pass # the directory does not exist
            except OSError as e:
                print('removed %s catch %s' % (root, e))

def main(argv=None):
    if argv is None:
        argv = sys.argv
    try:
        args = argv[1:]
        if args:
            cleanup(args[0], include_self=False)
    except: # pylint: disable=W0703
        traceback.print_exc()

if __name__ == '__main__':
    main()
