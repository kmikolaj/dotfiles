#!/usr/bin/env python

"""
sway-alt-tab.py --

Add the following lines to your ``.sway/config``:

Switch only on current workspace only (default)
```
    set $swayt_alt_tab        path/to/sway-alt-tab.py n
    set $swayt_alt_shift_tab  path/to/sway-alt-tab.py p
    bindsym Mod1+Tab exec   exec $swayt_alt_tab
    bindsym Mod1+Shift+Tab  exec $swayt_alt_shift_tab
```

Switch all windows
```
    set $swayt_alt_tab        path/to/sway-alt-tab.py n all
    set $swayt_alt_shift_tab  path/to/sway-alt-tab.py p all
    bindsym Mod1+Tab exec   exec $swayt_alt_tab
    bindsym Mod1+Shift+Tab  exec $swayt_alt_shift_tab
```
"""

import os
import subprocess
import json

ignore_name = ['__i3']
ignore_type = ['dockarea']

if 'SWAYSOCK' in os.environ:
    windowTxt = 'pid'
    idTxt = 'pid'
else:
    windowTxt = 'window'
    idTxt = 'id'


class Windows(object):
    def __init__(self):
        self.ws = {}
        self.cur_id = None
        self.cur_wsname = None
        self.cur_out = None
        self.fs = set()

    def add(self, ws, node):
        wsname = ws[0]
        output = ws[1]
        if wsname in self.ws:
            self.ws[wsname].append(node)
        else:
            self.ws[wsname] = [node]
        if node['focused']:
            self.cur_id = node['id']
            self.cur_wsname = wsname
            self.cur_output = output

    def parse(self, tree, wsname):
        if tree['name'] in ignore_name:
            return
        if tree['type'] in ignore_type:
            return
        if 'nodes' in tree and len(tree['nodes']):
            for node in tree['nodes']:
                if node['type'] == 'workspace':
                    wsname = (node['name'], node['output'])
                self.parse(node, wsname)
        else:
            if windowTxt in tree and tree[windowTxt] is not None:
                if tree['fullscreen_mode'] == 1:
                    self.fs.add(wsname[1])
                self.add(wsname, tree)


def select_window_id(windows, reverse_mode=False, current_workspace_only=True):
    if current_workspace_only:
        ws = windows.ws[windows.cur_wsname]
    else:
        ws = []
        for v in windows.ws.values():
            ws += v
    if reverse_mode:
        ws.reverse()
    selected = ws[-1]
    for node in ws:
        if node['id'] == windows.cur_id:
            break
        selected = node
    return selected[windowTxt]


def main(argv=None):
    output = subprocess.check_output(['swaymsg', '-t', 'get_tree'])
    tree = json.loads(output)

    wins = Windows()
    wins.parse(tree, 'root')

    if wins.cur_output in wins.fs:
        return

    argv_len = len(argv)
    reverse_mode = True
    current_workspace_only = True
    if argv_len >= 2:
        cmd = argv[1].lower()
        if cmd[0] == 'n':
            reverse_mode = True
        elif cmd[0] == 'p':
            reverse_mode = False
        else:
            raise ValueError('specify [n]ext or [p]rev')
    if argv_len >= 3:
        cmd = argv[2].lower()
        if cmd[0] == 'c':
            current_workspace_only = True
        elif cmd[0] == 'a':
            current_workspace_only = False
        else:
            raise ValueError('specify [c]urrent or [a]ll')
    id = select_window_id(wins, reverse_mode, current_workspace_only)

    subprocess.check_call(['swaymsg', '[%s="%d"] focus' % (idTxt, id)])


if __name__ == '__main__':
    import sys
    sys.exit(main(argv=sys.argv))
