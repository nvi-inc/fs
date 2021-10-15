import socket

import pytest

from notifications import Notifications

hostname = socket.gethostname()

addresses_to_test = {
    "jejlovell@gmail.com",
    "jim.lovell@utas.edu.au",
    "jlovellau@yahoo.com.au",
}

addresses_to_test_ed_mario = {
    "jejlovell@gmail.com",
    "jim.lovell@utas.edu.au",
    "jlovellau@yahoo.com.au",
    "ed.himwich@nviinc.com",
    "ed.himwich@nasa.gov",
    "mario.berube@nasa.gov",
    "mario.berube@nviinc.com",
    "mariopberube@gmail.com",
}


@pytest.mark.skipif("pcfs" not in hostname, reason="only expected to work at Hobart")
def test_send_email():
    print("hostname = {}".format(hostname))
    smtp_server = "localhost"
    email_sender = "jejlovell@gmail.com"
    email_recipients = "jim.lovell@utas.edu.au"
    notify = Notifications(smtp_server, email_sender, email_recipients)
    subject = "This is a test"
    message = (
        "Message body:\nHello,\nThis is a test of the fesh2 mail alert system\nSender:"
        "{}\nRecipient = {}".format(email_sender, email_recipients)
    )
    assert not notify.send_email(subject, message)


@pytest.mark.skipif("pcfs" not in hostname, reason="only expected to work at Hobart")
@pytest.mark.parametrize("recipients", addresses_to_test)
def test_send_email_pcfs2ho(recipients):
    smtp_server = "smtp.gmail.com"
    email_sender = "hobart26m@gmail.com"
    email_recipients = recipients
    password = "wichetty"
    port = 587
    notify = Notifications(
        smtp_server, email_sender, email_recipients, password=password, smtp_port=port
    )
    subject = "This is a test"
    message = (
        "Message body:\nHello,\nThis is a test of the fesh2 mail alert system\nSender:"
        "{}\n\nRecipient = {}".format(email_sender, email_recipients)
    )
    assert notify.send_email(subject, message)


@pytest.mark.skipif("mgo" not in hostname, reason="only expected to work at SGP sites")
@pytest.mark.parametrize("recipients", addresses_to_test_ed_mario)
def test_send_email_fs2_01(recipients):
    smtp_server = "ndc-relay.ndc.nasa.gov"
    email_sender = "jelovel1@fs2-mg.sgp.nasa.gov"
    email_recipients = recipients
    notify = Notifications(smtp_server, email_sender, email_recipients)
    subject = "This is a test of fs2 -> Jim"
    message = (
        "Hello,\nThis is a test of the fesh2 mail alert system\nSender:"
        "{}\nRecipient: {}".format(email_sender, email_recipients)
    )
    assert notify.send_email(subject, message)
