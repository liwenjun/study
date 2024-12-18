// 如启用bulma模块，请先安装sass
// yarn add -D sass
//
//import "../node_modules/bulma/sass/utilities/_all.sass";
//import "../node_modules/bulma/sass/elements/button.sass";
//import "../node_modules/bulma/sass/elements/table.sass";
//import "../node_modules/bulma/bulma.sass";

import "../node_modules/@cityssm/bulma-sticky-table/bulma-with-sticky-table.css";

import { invoke } from "@tauri-apps/api";

// 调用命令
// invoke("click", { acid: 100 }).then((response) => console.log(response));
console.log("启动...");

import { Elm } from "./Main.elm";

const root = document.querySelector("#app div");
const app = Elm.Main.init({ node: root });

// 获取新闻列表
app.ports.getNewsList.subscribe(function () {
  invoke("news").then((response) => app.ports.newsReceiver.send(response));
});

// 点击新闻
app.ports.sendClick.subscribe(function (acid) {
  invoke("click", { acid: acid }).then((response) => app.ports.clickReceiver.send(response));
});
