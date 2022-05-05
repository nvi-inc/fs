import pytest
import logging
from logging import FeshLog

logger = logging.getLogger(__name__)
DEBUG = False

levels_to_test = {
    logging.DEBUG,
    logging.INFO,
    logging.WARNING,
    logging.CRITICAL,
}
@pytest.mark.parametrize("level", levels_to_test)
def test_fesh_log(level):
    log = FeshLog("/tmp", "Test.log", quiet=False, level=level)
    logger.info(f"level = {level} Info message")
    logger.debug(f"level = {level} Debug message")
    logger.warning(f"level = {level} warning message")
    logger.critical(f"level = {level} critical message")
    assert True

if __name__ == "__main__":
    test_fesh_log(level=logging.DEBUG if DEBUG else logging.INFO)
