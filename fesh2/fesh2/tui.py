#!/usr/bin/env python
import datetime
import logging

import urwid
from additional_urwid_widgets import IndicativeListBox

TUI_REFRESH_INTERVAL_SEC = 0.2
STATUS_UPDATE_INTERVAL_SEC = 60

logger = logging.getLogger(__name__)


class FeshTUI:
    """
    Setup and run a Fesh Text User Interface

    Usage example:
    # Initialise the text interface
    TextUI = FeshTUI(update_status, update_status_args)
    TextUI.loop.set_alarm_in(TUI_REFRESH_INTERVAL_SEC, TextUI.animate_progress_bar)
    TextUI.loop.run()
    """

    def __init__(self, func, func_args, config):
        """
        func = function to call when refreshing the status info
        func_args = any arguments func needs
        """
        self.func = func
        self.func_args = func_args
        self.station_code_txt = " ".join(config.Stations).title()
        self.title = "Fesh2 status for {}".format(self.station_code_txt)
        self.sess_lines = {}
        self.config = config
        self.progress_bar_completion = 0.0
        self.wait_time_sec = STATUS_UPDATE_INTERVAL_SEC
        self.next_update_datetime = datetime.datetime.now() + datetime.timedelta(
            seconds=self.wait_time_sec
        )

        self.palette = [
            ("default", "white", "black"),
            ("banner", "black", "white"),
            ("banner_blue", "black", "light blue"),
            ("red", "dark red", "yellow"),
            ("red_fg", "light red", "default"),
            ("streak", "black", "dark red"),
            ("bg", "black", "dark gray"),
            ("underline", "white, underline", ""),
            ("pg normal", "white", "black", "standout"),
            ("pg complete", "black", "white"),
            ("pg smooth", "dark magenta", "black"),
            ("reveal_focus", "white", "dark gray"),
            ("ilb_barActive_focus", "dark cyan", "light gray"),
            ("ilb_barActive_offFocus", "light gray", "dark gray"),
            ("ilb_barInactive_focus", "light cyan", "dark gray"),
            ("ilb_barInactive_offFocus", "black", "dark gray"),
        ]

        # Build the TUI...:
        # -----------------------------------------------------------------------------------------
        # Dividers...
        self.div_dash = urwid.Divider("-")
        self.div_empty = urwid.Divider()
        # -----------------------------------------------------------------------------------------
        # Title
        txt_title = urwid.Text(self.title, align="center")
        map1 = urwid.AttrMap(txt_title, "banner")
        # -----------------------------------------------------------------------------------------
        # Station ID
        self.txt_station_id = urwid.Text(
            ("bg", "Schedule Status for mg"), align="center"
        )
        # -----------------------------------------------------------------------------------------
        # Number of active Fesh2 processes. Sets self.txt_number_processes
        processes_text = self._get_processes_text()
        self.processes_text_urwid = urwid.Text(processes_text, align="left")
        reprocess_text = self._get_reprocess_notes()
        self.reprocess_text_urwid = urwid.Text(reprocess_text, align="left")
        self._get_number_processes_urwid()
        # -----------------------------------------------------------------------------------------
        # Master file versions.
        ## Header
        self.txt_mst_hdr = urwid.Text(
            (
                "",
                "UT of latest download:",
            ),
            align="left",
        )
        ## 24h sessions
        txt_mst_24h = urwid.Text("24h sessions:", align="right")
        self.vartxt_24h = urwid.Text("", align="left")
        line_24h = urwid.Columns([txt_mst_24h, self.vartxt_24h], dividechars=2)
        ## Intensive sessions
        txt_mst_int = urwid.Text("Intensive sessions:", align="right")
        self.vartxt_int = urwid.Text("")
        line_int = urwid.Columns([txt_mst_int, self.vartxt_int], dividechars=2)
        self.update_txt_master()
        # -----------------------------------------------------------------------------------------
        # Sessions
        ## Header
        txt_sessions = urwid.Text(("underline", "Sessions:"), align="left")
        # TODO: Add a second header line when we have multiple stations
        self.txt_col_headers = [
            "Session",
            "Start (UT)",
            "Got schedule?",
            "Age (hrs)*",
            "FS files prepared?",
        ]
        # column widths for Session list
        self.col_widths = []
        for n, txt in enumerate(self.txt_col_headers):
            self.col_widths.extend([len(txt)])

        self.sess_header_line = self.session_summary_line(
            self.txt_col_headers, align="center"
        )
        ## ----------------------------------------------------------------------------------------
        ## fills the dict self.sess_lines
        self.get_sess_lines(style="default")
        # call this again as column widths may have changed
        self.sess_header_line = self.session_summary_line(
            self.txt_col_headers, align="center"
        )
        ## ----------------------------------------------------------------------------------------
        ## Key for session table
        self.txt_key_header = urwid.Padding(
            urwid.Text(("underline", "Key:"), align="left"),
            min_width=20,
            left=2,
            right=2,
        )
        self.txt_key_default_str = (
            "[*] Age = time since the schedule file was released.\n"
        )
        self.txt_key = urwid.Text(self.txt_key_default_str, align="left")
        self.txt_key_reprocess_str = self._highlight_substr(
            self._get_reprocess_key_text(), "**", "red_fg"
        )
        self.update_txt_key()

        # -----------------------------------------------------------------------------------------
        # Progress bar to show when next check will be
        self.utxt_progressbar_caption = urwid.Text("")
        self.progress_bar = urwid.ProgressBar(
            "pg normal", "pg complete", 0, 1, "pg smooth"
        )
        self.progress_bar.set_completion(self.progress_bar_completion)

        # -----------------------------------------------------------------------------------------
        # Text to go at the bottom to show what keys do
        help_txt = " Q = Quit  |  P = Fesh2 processes  |  R = Reprocessing notes "
        help_bar = urwid.Text(help_txt, align="center")
        map_help = urwid.AttrMap(help_bar, "bg")
        # -----------------------------------------------------------------------------------------
        # -----------------------------------------------------------------------------------------
        # Make the pile, row by row
        pile_arr = [
            map1,
            # div_empty,
            # self.txt_station_id,
            self.txt_number_processes,
            self.div_empty,
            urwid.LineBox(
                urwid.Pile(
                    [
                        urwid.Padding(self.txt_mst_hdr, left=2, right=2),
                        urwid.Padding(line_24h, left=2, right=2),
                        urwid.Padding(line_int, left=2, right=2),
                    ]
                ),
                title="Master files",
                title_align="left",
            ),
            self.div_empty,
        ]
        pile_sessions = [self.sess_header_line]
        pile_sessions.extend(self.sess_lines.values())
        pile_sessions.extend(
            [
                self.div_dash,
                self.txt_key_header,
                urwid.Padding(self.txt_key, min_width=20, left=2, right=2),
            ]
        )
        # for row in self.sess_lines.values():
        #     pile_arr += [row]

        self.sessions_linebox = urwid.LineBox(
            urwid.Pile(pile_sessions),
            title="Sessions in the next {:d} days:".format(
                int(self.config.LookAheadTimeDays)
            ),
            title_align="left",
        )
        self.sessions_box_pile_position = len(pile_arr)
        pile_arr.extend(
            [
                self.sessions_linebox,
                self.div_empty,
                # div_dash,
                self.utxt_progressbar_caption,
                # self.progress_bar,
                # div_empty,
                map_help,
            ]
        )

        self.pile = urwid.Pile(pile_arr)
        self.pile_filler = urwid.Filler(self.pile, valign="top")

        layout = self.dialog("Reprocessing a schedule", self.reprocess_text_urwid)
        reprocess_dialog_pile = urwid.Pile([layout])
        self._reprocess_dialog = urwid.Overlay(
            reprocess_dialog_pile,
            self.pile_filler,
            align="center",
            valign="middle",
            width=("relative", 100),
            height=("relative", 100),
            min_width=len(max(reprocess_text.splitlines(), key=len)),
            min_height=reprocess_text.count("\n"),
        )

        layout = self.dialog("Fesh2 processes", self.processes_text_urwid)
        self.proc_dialog_pile = urwid.Pile([layout])
        self._proc_dialog = urwid.Overlay(
            self.proc_dialog_pile,
            self.pile_filler,
            align="center",
            valign="middle",
            width=("relative", 100),
            height=("relative", 100),
            min_width=len(max(reprocess_text.splitlines(), key=len)),
            min_height=reprocess_text.count("\n"),
        )

        self.loop = urwid.MainLoop(
            self.pile_filler, self.palette, unhandled_input=self._handle_input
        )

    def goto_main_widget(self, thing):
        self.loop.widget = self.pile_filler

    def dialog(self, title: str, urwid_text: urwid.Text):
        """
        Overlays a dialog box on top of the console UI
        """

        # Header
        header_text = urwid.Text(
            ("banner_blue", "{} (use arrow keys to navigate)".format(title)),
            align="center",
        )
        header = urwid.AttrMap(header_text, "banner_blue")

        # Body
        lw = urwid.SimpleListWalker([urwid_text])
        body_text = IndicativeListBox(lw)
        body_text = urwid.AttrMap(body_text, "selectable", "reveal_focus")
        body = urwid.LineBox(body_text)

        # Footer
        footer = urwid.Button("OK", self.goto_main_widget)
        footer = urwid.AttrWrap(footer, "selectable", "reveal_focus")
        footer = urwid.GridFlow([footer], 8, 1, 1, "center")

        # Layout
        layout = urwid.Pile([("pack", header), body, ("pack", footer)])

        return layout

    def get_sess_lines(self, style="default"):
        """
        Given session schedule status info, returns a dict containing urwid AttrMaps
        to be displayed (an urwid row per session)
        config = fesh2 config parameters defines in FeshConfig
        """
        if self.config.tui_data["sessions"]:
            for i, sess in enumerate(self.config.tui_data["sessions"]):
                self.sess_lines[i] = self.session_summary_line(
                    self.config.tui_data["sessions"][sess], style=style
                )
        else:
            self.sess_lines = {}
            text_list = ["- None -", "--", "-", "-", "-"]
            self.sess_lines[0] = self.session_summary_line(text_list, style=style)

    def session_summary_line(
        self, text_list: list, style: str = "bg", align: str = "center"
    ) -> urwid.AttrMap:
        """
        Given a list of text strings, returns an urwid AttrMap containing urwid.Columns
        ready to be placed in a row
        """
        columns_arr = {}
        # Expand col_widths if necessary (may happen if multiple antennas are bing monitored)
        for n, coltxt in enumerate(text_list):
            if len(coltxt) > self.col_widths[n]:
                self.col_widths[n] = len(coltxt)
        # Fill a row with columns for each category
        for n, coltxt in enumerate(text_list):
            # highlight the ** if it's there
            coltxt = self._highlight_substr(coltxt, "**", "red_fg")
            columns_arr[n] = (
                self.col_widths[n],
                urwid.AttrMap(urwid.Text(coltxt, align=align), style),
            )
        map = urwid.AttrMap(
            urwid.Columns(list(columns_arr.values()), dividechars=2), "default"
        )
        return map

    def animate_progress_bar(self, loop=None, user_data=None):
        """update the wait time progress bar and schedule the next update"""
        do_update = False
        debug_fh = open("debug.txt", "a")
        prefix = "Next update in "
        now = datetime.datetime.now()
        time_to_go_sec = (self.next_update_datetime - now).seconds
        debug_fh.write(
            "now {} next{} tgs {} wts {} d {}\n".format(
                now,
                self.next_update_datetime,
                time_to_go_sec,
                self.wait_time_sec,
                self.wait_time_sec,
            )
        )
        if time_to_go_sec > 0:
            # if time_gone_sec < 0:
            #     time_gone_sec = 0
            self.progress_bar_completion = (
                self.wait_time_sec - time_to_go_sec
            ) / self.wait_time_sec
            debug_fh.write(
                "comp {} wts {}\n".format(
                    self.progress_bar_completion, self.wait_time_sec
                )
            )
            txt = "{}{:d} s".format(prefix, int(time_to_go_sec))
            self.utxt_progressbar_caption.set_text(txt)
            self.progress_bar.set_completion(self.progress_bar_completion)
        else:
            self.progress_bar_completion = 1.0
            debug_fh.write("time for an update\n")
            self.utxt_progressbar_caption.set_text("Time for an update")
            self.progress_bar.set_completion(self.progress_bar_completion)
            self.loop.draw_screen()
            do_update = True

        self.loop.set_alarm_in(TUI_REFRESH_INTERVAL_SEC, self.animate_progress_bar)
        if do_update:
            debug_fh.write("Calling update\n")
            self.run_update()
            # TODO:
            # Check that everything updates, including master schedule times
            do_update = False

        debug_fh.close()

    def run_update(self):
        self.func(self.func_args)
        self.update_txt_processes()
        self.update_txt_master()
        ## fills the dict self.sess_lines
        self.get_sess_lines(style="default")
        self.update_txt_sessions()
        self.update_txt_key()
        self.next_update_datetime = datetime.datetime.now() + datetime.timedelta(
            seconds=self.wait_time_sec
        )
        self.loop.draw_screen()

    def update_txt_processes(self):
        if self.config.tui_data["processes_warning"]:
            # the message contains a warning, make it red
            txt = "{} Press P for help".format(self.config.tui_data["processes"])
            self.txt_number_processes.base_widget.set_text(txt)
            self.txt_number_processes.set_attr_map({None: "red"})
            self.processes_text_urwid.set_text(self._get_HowToStartFesh_text())
        else:
            txt = "Fesh2 is running. Press 'P' for details."
            self.txt_number_processes.base_widget.set_text(txt)
            self.txt_number_processes.set_attr_map({None: "default"})
            self.processes_text_urwid.set_text(self.config.tui_data["processes_list"])

    def update_txt_master(self):
        if self.config.tui_data["vartxt_24h"]:
            self.vartxt_24h.set_text(self.config.tui_data["vartxt_24h"])
        if self.config.tui_data["vartxt_int"]:
            self.vartxt_int.set_text(self.config.tui_data["vartxt_int"])

    def update_txt_sessions(self):
        """"""
        pile_sessions = [self.sess_header_line]
        pile_sessions.extend(self.sess_lines.values())
        pile_sessions.extend(
            [
                self.div_dash,
                self.txt_key_header,
                urwid.Padding(self.txt_key, min_width=20, left=2, right=2),
            ]
        )
        # for row in self.sess_lines.values():
        #     pile_arr += [row]

        self.sessions_linebox = urwid.LineBox(
            urwid.Pile(pile_sessions),
            title="Sessions in the next {:d} days:".format(
                int(self.config.LookAheadTimeDays)
            ),
            title_align="left",
        )

        self.pile.contents[self.sessions_box_pile_position] = (
            self.sessions_linebox,
            ("weight", 1),
        )
        # self.pile._invalidate()

        # if self.config.tui_data["sessions"]:
        #     for sess in self.sess_lines:
        #         self.sess_lines[sess]._invalidate()

    def update_txt_key(self):
        if self.config.tui_data["reprocess_note"]:
            text = [
                [self.txt_key_default_str],
                self.txt_key_reprocess_str,
            ]
            text = [item for sublist in text for item in sublist]
            self.txt_key.set_text(text)
            # print(f"Text = {text}")
        else:
            self.txt_key.set_text("{}".format(self.txt_key_default_str))

    def _handle_input(self, key: str):
        """
        If 'q' or 'Q' is pressed, exits main loop
        """
        if key in ("q", "Q"):
            raise urwid.ExitMainLoop()
        if key in ("p", "P"):
            # show Fesh2 processes
            self.loop.widget = self._proc_dialog
        if key in ("r", "R"):
            # show processing notes
            self.loop.widget = self._reprocess_dialog

    def _get_number_processes_urwid(self):
        processes_txt = self.config.tui_data["processes"]
        uT = urwid.Text(processes_txt, align="left")
        self.txt_number_processes = urwid.AttrMap(uT, "default")
        self.update_txt_processes()
        return

    def _get_processes_text(self):
        return self.config.tui_data["processes_list"]

    def _intersperse(self, lst: list, item: str) -> list:
        """Intersperse items in a list

        https://stackoverflow.com/questions/5920643/add-an-item-between-each-item-already-in-the-list
        """
        result = [item] * (len(lst) * 2 - 1)
        result[0::2] = lst
        return result

    def _highlight_substr(self, text: str, substring: str, attribute: str) -> list:
        """Highlight an given substring of a piece of text

        Returns a list suitable for urwid's Text or set_text"""
        arr = text.split(substring)
        return self._intersperse(arr, (attribute, substring))

    def _get_reprocess_key_text(self):
        return (
            '[**] A new schedule file has been downloaded but not drudged. Press "R" for '
            "instructions. "
        )

    def _get_reprocess_notes(self):
        return """If you see "**" next to a session then a new schedule file has 
been downloaded but not drudged. 

A backup of the previous version has been kept, but it also 
exists with its original name. The new schedule is called 
<session_code>.skd.new and should be drudged if it is to be 
used. To drudg the new file by hand:
  
      cd <schedule files directory>
      mv <session_code>.skd.new <session_code>.skd
      drudg <session_code>.skd
  
Or force fesh2 to update the schedules with the following 
command:

      fesh2 --update --once --DoDrudg -g <session_code>

where <session_code> is the code for the session to be 
updated (e.g. r4951). The backed-up original file is called 
<session_code>.skd.bak.N
"""

    def _get_HowToStartFesh_text(self):
        return """
Fesh2 is not currently running so no schedule 
checks or processing will be done. To start fesh2, simply 
type this in a terminal window:

    fesh2

See the documentation for more information on 
command-line options and running fesh2 as a service.    
        """


class PopUpDialog(urwid.WidgetWrap):
    """A dialog that appears with nothing but a close button"""

    signals = ["close"]

    def __init__(self):
        close_button = urwid.Button("that's pretty cool")
        urwid.connect_signal(close_button, "click", lambda button: self._emit("close"))
        pile = urwid.Pile(
            [
                urwid.Text(
                    "^^  I'm attached to the widget that opened me. "
                    "Try resizing the window!\n"
                ),
                close_button,
            ]
        )
        fill = urwid.Filler(pile)
        self.__super.__init__(urwid.AttrWrap(fill, "popbg"))


class ThingWithAPopUp(urwid.PopUpLauncher):
    def __init__(self):
        self.__super.__init__(urwid.Button("click-me"))
        urwid.connect_signal(
            self.original_widget, "click", lambda button: self.open_pop_up()
        )

    def create_pop_up(self):
        pop_up = PopUpDialog()
        urwid.connect_signal(pop_up, "close", lambda button: self.close_pop_up())
        return pop_up

    def get_pop_up_parameters(self):
        return {"left": 0, "top": 1, "overlay_width": 32, "overlay_height": 7}
