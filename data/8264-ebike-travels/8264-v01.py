# -*- coding: utf-8 -*-

import requests
from bs4 import BeautifulSoup
from markdownify import markdownify as md

home_url = 'https://www.8264.com/'
urls = ['https://www.8264.com/youji/5374591.html?from=8264bbs',
        'https://www.8264.com/youji/5369855.html?from=8264bbs',
        'https://www.8264.com/youji/5361461.html?from=8264bbs',
        'https://www.8264.com/youji/5348458.html?from=8264bbs',
        'https://www.8264.com/youji/5340155.html?from=8264bbs',
        'https://www.8264.com/youji/5314368.html?from=8264bbs',
        'https://www.8264.com/youji/5333007.html?from=8264bbs',
        'https://www.8264.com/youji/5419384.html?from=8264bbs',
        'https://www.8264.com/youji/5425184.html?from=8264bbs',
        'https://www.8264.com/youji/5493377.html?from=8264bbs',
        'https://www.8264.com/youji/5556083.html?from=8264bbs',
        'https://www.8264.com/youji/5611918.html?from=8264bbs',
        'https://www.8264.com/youji/5656980.html?from=8264bbs',
        'https://www.8264.com/wenzhang/5638329.html?from=8264bbs',
        'https://www.8264.com/youji/5694915.html?from=8264bbs',
        'https://www.8264.com/youji/5719165.html?from=8264bbs']


def get_page(url):
    """获取第一页信息
    """
    res = requests.get(url).text
    html = BeautifulSoup(res, "html.parser")
    return get_content(html)


def get_content(html):
    """获取页面内所需内容
    """
    # data = html.find_all('div', class_ = 'blk-container')
    data = html.find('div', class_='blk-container')
    title = data.find('h1').get_text()
    pages = data.find('div', class_='pg')
    content = data.find('div', class_='art-content')

    # 处理图片链接
    for img in content.find_all('img', class_='lazy preview'):
        img['src'] = img['data-original']

    return title, pages, content


def parse_pages(pages):
    """解析除了第一页外的所有页面"""
    lastpage = pages.find('a', class_='last')
    if lastpage is not None:
        a1 = lastpage['href'].split('-')
        b1 = a1[1].split('.')
        cnt = int(b1[0])
        return ['%s-%d.%s' % (a1[0], x, b1[1]) for x in range(2, cnt + 1)]
    else:
        vals = pages.find_all('a')
        rets = [x['href'] for x in vals]
        rets.pop()
        return rets


def write_md(title, contents):
    with open('z:\\%s.md' % (title, ), 'wt', encoding='utf-8') as f:
        for d in contents:
            print(md(str(d)), file=f)


def one(url):
    (t, p, d) = get_page(url)
    print(t)
    vs = []
    vs.append(d)
    for p in parse_pages(p):
        (_, _, data) = get_page(home_url + p)
        vs.append(data)
    write_md(t, vs)


def main():
    for url in urls:
        one(url)


if __name__ == "__main__":
    main()
