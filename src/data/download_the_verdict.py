import logging
import urllib.request
from pathlib import Path

import click
from dotenv import find_dotenv, load_dotenv


@click.command()
@click.option("-o", "--output-path", type=click.Path())
def download_the_verdict(output_path):
    """Function to make analysis-ready datasets."""

    logger = logging.getLogger(__name__)
    logger.info("making final data set from raw data")
    url = (
        "https://raw.githubusercontent.com/rasbt/"
        "LLMs-from-scratch/main/ch02/01_main-chapter-code/"
        "the-verdict.txt"
    )
    urllib.request.urlretrieve(url, output_path)


if __name__ == "__main__":
    log_fmt = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    logging.basicConfig(level=logging.INFO, format=log_fmt)

    # not used in this stub but often useful for finding various files
    project_dir = Path(__file__).resolve().parents[2]

    # find .env automagically by walking up directories until it's found, then
    # load up the .env entries as environment variables
    load_dotenv(find_dotenv())

    download_the_verdict()
