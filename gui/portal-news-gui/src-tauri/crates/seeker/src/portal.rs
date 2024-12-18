use crate::{ClickSettings, SectionSettings};
use anyhow::{Context, Result};
use regex::Regex;
use scraper::{Html, Selector};
use serde::Serialize;
use url::Url;

#[derive(Debug, Serialize)]
pub struct Record {
    pub date: String,
    pub url: String,
    pub title: String,
    pub acid: usize,
    pub click: usize,
}

#[derive(Debug, Serialize)]
pub struct Click {
    pub acid: usize,
    pub click: usize,
}

fn get_html(uri: &str) -> Result<Html> {
    let response = ureq::get(uri)
        .call()
        .with_context(|| format!("打开 {} 出错！", uri))?;
    Ok(Html::parse_document(&response.into_string()?))
}

// 解析点击数
// <html><center><font color=red style='font-size:12px;'>689</font></center></html>
fn parse_click(html: &Html) -> usize {
    let selector = Selector::parse("font").unwrap();
    let node = html.select(&selector).next().unwrap();
    let text = node.text().next().unwrap_or_default();
    text.parse().unwrap_or(0)
}

// 解析新闻列表
fn parse_news(html: &Html, uri: &str, re: &Regex, click: &ClickSettings) -> Vec<Record> {
    let mut ret = Vec::new();

    let selector = Selector::parse("a[href]").unwrap();
    let fselector = Selector::parse("font").unwrap();
    let nodes = html
        .select(&selector)
        .into_iter()
        .filter(|p| re.is_match(p.value().attr("href").unwrap_or_default()))
        .filter(|p| p.select(&fselector).count() > 0);

    for node in nodes {
        let title = node
            .select(&fselector)
            .next()
            .unwrap()
            .text()
            .next()
            .unwrap_or_default();

        if title.contains("xx公司") {
            let href = node.value().attr("href").unwrap_or_default();
            let url =
                Url::parse(href).unwrap_or_else(|_| Url::parse(uri).unwrap().join(href).unwrap());

            let caps = re.captures(href).unwrap();
            let acid = caps
                .name("acid")
                .unwrap()
                .as_str()
                .parse::<usize>()
                .unwrap_or_default();
            let date = caps.name("date").unwrap().as_str();
            let click = click_(acid, click);

            ret.push(Record {
                url: url.to_string(),
                date: date.to_owned(),
                title: title.to_owned(),
                acid,
                click,
            });
        }
    }

    ret
}

fn get_news(uri: &str, re: &Regex, click: &ClickSettings) -> Vec<Record> {
    match get_html(uri) {
        Ok(html) => parse_news(&html, uri, re, click),
        Err(_) => vec![],
    }
}

fn section_(sec: &SectionSettings, click: &ClickSettings) -> Vec<Record> {
    let uris = sec.get_urls();
    let re =
        Regex::new(r"\.\./main/article/(?P<date>\d{6})/article(?P<acid>\d{7,})\.shtml$").unwrap();

    let mut ret: Vec<Record> = Vec::new();
    for uri in &uris {
        ret.append(&mut get_news(uri, &re, click));
    }
    ret
}

pub fn news(secs: &[SectionSettings], click: &ClickSettings) -> Vec<Record> {
    let mut ret: Vec<Record> = Vec::new();
    for sec in secs {
        ret.append(&mut section_(sec, click));
    }
    ret
}

fn click_(acid: usize, click: &ClickSettings) -> usize {
    match get_html(&click.get_url(acid)) {
        Ok(html) => parse_click(&html),
        Err(_) => 0,
    }
}

pub fn click(acid: usize, click: &ClickSettings) -> Click {
    for _x in 1..click.count {
        click_(acid, click);
        std::thread::sleep(std::time::Duration::from_millis(click.interval))
    }
    Click {
        acid,
        click: click_(acid, click),
    }
}
