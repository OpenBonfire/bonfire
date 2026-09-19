//! A handle to one SCTP data channel - either created locally
//! ([`crate::api::peer_connection::RtcPeerConnection::create_data_channel`]) or handed
//! back after a [`crate::api::types::PeerConnectionEvent::DataChannel`] event
//! (`take_remote_data_channel`).
use std::sync::Arc;

use bytes::BytesMut;
use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use webrtc::data_channel::DataChannel as WrtcDataChannel;

use crate::api::runtime_ctx::runtime;
use crate::api::types::DataChannelEvent;

#[frb(opaque)]
pub struct RtcDataChannel {
    pub(crate) inner: Arc<dyn WrtcDataChannel>,
}

impl RtcDataChannel {
    pub async fn label(&self) -> Result<String, String> {
        self.inner.label().await.map_err(|e| e.to_string())
    }

    /// Sends a UTF-8 text message.
    pub async fn send_text(&self, text: String) -> Result<(), String> {
        self.inner.send_text(&text).await.map_err(|e| e.to_string())
    }

    /// Sends a binary message.
    pub async fn send_binary(&self, data: Vec<u8>) -> Result<(), String> {
        self.inner
            .send(BytesMut::from(&data[..]))
            .await
            .map_err(|e| e.to_string())
    }

    pub async fn close(&self) -> Result<(), String> {
        self.inner.close().await.map_err(|e| e.to_string())
    }

    /// Subscribes to this channel's lifecycle/message events. Each call spawns its own
    /// poll loop against the channel, so subscribe once per channel - a second
    /// subscription would race the first for each polled event rather than both
    /// seeing every event.
    pub async fn events(&self, sink: StreamSink<DataChannelEvent>) {
        let inner = Arc::clone(&self.inner);
        runtime().spawn(Box::pin(async move {
            while let Some(event) = inner.poll().await {
                if sink.add(event.into()).is_err() {
                    // Dart side dropped the stream - stop polling.
                    break;
                }
            }
        }));
    }
}
