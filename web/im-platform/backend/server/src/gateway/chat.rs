use crate::dispatch;
use crate::models::message::WsPayload;
use crate::models::{appstate::APP, gateway_event::GatewayEvent, message::Message};

pub async fn process_text(message: &str) {
    tracing::debug!("接收消息: {}", message);
    create_message(message).await;
}

pub fn process_binary(message: &[u8]) {
    tracing::debug!("接收消息: {:?}", message);
}

///
async fn create_message(message: &str) {
    let Ok(payload) = serde_json::from_str::<WsPayload>(message) else {
        tracing::error!("Json解码出错: {}", message);
        return;
    };
    
    let mid = payload.nonce.clone(); // TODO: 暂用于私发消息
    let mut message = Message::from_wspayload(payload).await;

    match mid {
        Some(u) => {
            let uid = u.clone().parse::<i64>().expect("user_id Error");
            tracing::debug!("发送用户消息: {}", uid);
            message.set_nonce("这是一条私信");
            APP.gateway
                .write()
                .await
                .send_to(uid.into(), GatewayEvent::MessageCreate(message.clone()));
        }
        None => {
            dispatch!(GatewayEvent::MessageCreate(message.clone()));
        }
    }
}
