import unittest
from unittest.mock import patch

import wishingfn.cli as cli


class TargetTextTests(unittest.TestCase):
    def test_empty_clipboard_error_marker_is_empty(self):
        self.assertTrue(cli.is_empty_clipboard_error('CLIPBOARD selection doesn\'t exist or form "STRING" not defined'))

    def test_accepts_selection_when_no_prior_clipboard(self):
        self.assertTrue(cli.should_accept_copied_selection('', 'selected text', False))

    def test_rejects_unchanged_prior_clipboard_as_selection(self):
        self.assertFalse(cli.should_accept_copied_selection('old clipboard', 'old clipboard', True))

    def test_restores_empty_prior_clipboard_when_it_existed(self):
        with patch.object(cli, 'write_clipboard') as write_clipboard:
            cli.restore_clipboard('', True)
        write_clipboard.assert_called_once_with('')

    def test_does_not_restore_when_prior_clipboard_unreadable(self):
        with patch.object(cli, 'write_clipboard') as write_clipboard:
            cli.restore_clipboard('', False)
        write_clipboard.assert_not_called()


class OpenValueTests(unittest.TestCase):
    def test_url_uses_browser(self):
        with patch.object(cli.webbrowser, 'open') as browser_open:
            self.assertEqual(cli.open_value('https://example.com', 'url'), 0)
        browser_open.assert_called_once_with('https://example.com')

    def test_command_uses_run_command(self):
        with patch.object(cli, 'run_command', return_value=0) as run_command:
            self.assertEqual(cli.open_value('echo hello', 'command'), 0)
        run_command.assert_called_once_with('echo hello')


class CommandExecutionTests(unittest.TestCase):
    def test_windows_command_opens_persistent_console(self):
        with patch.object(cli.platform, 'system', return_value='Windows'), patch.object(cli.subprocess, 'Popen') as popen:
            self.assertEqual(cli.run_command('echo hello'), 0)

        args, kwargs = popen.call_args
        self.assertEqual(args[0][:5], ['powershell.exe', '-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass'])
        self.assertEqual(args[0][-2:], ['-Command', 'echo hello'])
        self.assertEqual(kwargs['creationflags'], cli.subprocess.CREATE_NEW_CONSOLE)

    def test_linux_terminal_command_holds_window(self):
        command = cli.terminal_command('/usr/bin/gnome-terminal', 'echo hello')
        self.assertIn('--', command)
        self.assertIn('read _', command[-1])


if __name__ == '__main__':
    unittest.main()
