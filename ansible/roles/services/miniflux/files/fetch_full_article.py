#!env python3

import requests
from bs4 import BeautifulSoup

def fetch_full_article(url: str) -> str:
    """Fetch the full article text from the given URL."""
    response = requests.get(url)
    response.raise_for_status()

    soup = BeautifulSoup(response.content, 'html.parser')

    # Assuming the main article content is within an HTML tag with class 'article-body'
    article_body = soup.find(class_='article-body')
    if article_body:
        return article_body.get_text(separator='\n')
    return ''

if __name__ == '__main__':
    import sys
    url = sys.argv[1]
    print(fetch_full_article(url))
