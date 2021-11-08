import logging
from email.message import EmailMessage
from textwrap import fill
from typing import Union, List
from smtplib import SMTP, SMTPConnectError, SMTPAuthenticationError
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import numpy as np
import socket

logger = logging.getLogger(__name__)


list_of_strings = List[str]


class Notifications:
    """Fesh2 can optionally send notifications if there's an error, human intervention is needed
    etc. Usage:

    from FeshNotifications import Notifications

    server = "myserver.thing.com"
    from_email = "harry@hogwarts.ed.uk"
    to_email = ["ron@min_of_magic.go.uk", "hermione@hogwarts.ed.uk"]
    notify = Notifications(server, from_email, to_email)

    subject = "Hagrid's birthday"
    message = "Don't forget:\nIt's Hagrid's birthday tomorrow\n\nRgds, H."

    notify.send_email(subject, message)
    """

    def __init__(
        self,
        smtp_server: str,
        email_sender: str,
        email_recipients: Union[list_of_strings, str],
        smtp_port: int = 0,
        server_password: str = None,
    ):
        """
        @param smtp_server: SMTP server name
        @param email_sender: email address of sender (the From: address in the header)
        @param email_recipients: email address of recipient or list of addresses if multiple
        recipients
        """
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.email_sender = email_sender
        self.password = server_password
        self.recipients = ",".join(np.atleast_1d(email_recipients))
        return

    def send_email(
        self, subject: str, message_plaintext: str, message_html: str = None
    ) -> bool:
        """
        Send an email to self.recipients

        Parameters
        ----------
        subject
            Email subject
        message_plaintext
            Message body (plain text version)
        message_html
            Message body (HTML version). If None then a plaintext-only email is sent
        """
        message_plaintext = fill(message_plaintext)
        if message_html:
            msg = MIMEMultipart("alternative")
        else:
            msg = EmailMessage()
        msg["Subject"] = subject
        msg["From"] = self.email_sender
        msg["To"] = self.recipients
        if message_html:
            msg.attach(MIMEText(message_plaintext, "plain"))
            msg.attach(MIMEText(message_html, "html"))
        else:
            msg.set_content(message_plaintext)

        it_worked = True
        try:
            logger.info(
                "Attempting connection to mail server {} on port {}".format(
                    self.smtp_server, self.smtp_port
                )
            )
            server = SMTP(self.smtp_server, self.smtp_port)
        except SMTPConnectError as e:
            logger.warning("Could not connect to mail server: {}".format(e))
            it_worked = False
        except socket.timeout as e:
            logger.warning("Timeout trying to connect to mail server: {}".format(e))
            it_worked = False
        except Exception as e:
            logger.warning(
                "Unexpected error while trying to connect to server: {}".format(e)
            )
            it_worked = False
        if it_worked:
            logger.info("Connected to mail server")
            try:
                server.ehlo()
                if self.password:
                    server.starttls()
                    server.ehlo()
                    server.login(self.email_sender, self.password)
                server.send_message(msg)
            except SMTPAuthenticationError as e:
                logger.warning(
                    "Could not send email: the username and/or password is incorrect".format(e)
                )
                it_worked = False
            except Exception as e:
                logger.warning("Could not send notification email: {}".format(e))
                it_worked = False
            finally:
                server.quit()

        return it_worked
