use config::{Config, File};
use serde::{Deserialize, Serialize};
use std::path::Path;

#[derive(Deserialize, Serialize, Debug)]
pub struct ClickSettings {
    pub url: String,
    pub key: String,
    pub interval: u64,
    pub count: usize,
}

impl ClickSettings {
    pub fn get_url(&self, acid: usize) -> String {
        format!("{}?{}={}", self.url, self.key, acid)
    }
}

#[derive(Deserialize, Serialize, Debug)]
pub struct SectionSettings {
    pub name: String,
    pub url: String,
    pub number: usize,
    pub key: String,
}

impl SectionSettings {
    pub fn get_urls(&self) -> Vec<String> {
        let mut ret = Vec::with_capacity(self.number);
        for x in 1..=self.number {
            ret.push(self.url.replace("{}", &x.to_string()))
        }
        ret
    }
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Settings {
    pub section: Vec<SectionSettings>,
    pub click: ClickSettings,
}

impl Default for Settings {
    fn default() -> Self {
        let section = vec![
            SectionSettings {
                name: "公司要闻".to_owned(),
                url: "/main/subject/8/ArticleList8_{}.html".to_owned(),
                number: 50,
                key: "xx公司".to_owned(),
            },
            SectionSettings {
                name: "基层动态".to_owned(),
                url: "/main/subject/1082/ArticleList1082_{}.html"
                    .to_owned(),
                number: 50,
                key: "xx公司".to_owned(),
            },
        ];
        let click = ClickSettings {
            url: "/util/Count1.jsp".to_owned(),
            key: "acId".to_owned(),
            interval: 50,
            count: 100,
        };
        Settings { section, click }
    }
}

pub fn get_configuration(p: &Path) -> Settings {
    if let Ok(c) = Config::builder()
        .add_source(File::with_name(p.to_str().unwrap_or("conf")))
        .build()
    {
        if let Ok(s) = c.try_deserialize() {
            return s;
        }
    }
    Settings::default()
}
