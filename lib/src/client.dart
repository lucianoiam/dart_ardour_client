/// Copyright © 2020 Luciano Iam <lucianito@gmail.com>
///
/// This library is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This library is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this library.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'package:stream_channel/stream_channel.dart';

import 'channel.dart';
import 'message.dart';

class ArdourClient {
  StreamChannel<Message> _channel;
  Uri _uri;
  Stream<Message> _stream;

  ArdourClient({host = '127.0.0.1', port = 3818}) {
    this._uri = Uri.parse('ws://$host:$port');
  }

  Stream<Message> get stream {
    return _stream;
  }

  ArdourClient connect() {
    this._channel = ArdourMessageChannel.connect(this._uri);
    this._stream = _channel.stream.asBroadcastStream();
    return this;
  }

  Future<double> getStripGain(int stripId) async {
    return await _sendAndReceiveSingle(Node.STRIP_GAIN, [stripId], []);
  }

  Future<double> getStripPan(int stripId) async {
    return await _sendAndReceiveSingle(Node.STRIP_PAN, [stripId], []);
  }

  Future<bool> getStripMute(int stripId) async {
    return await _sendAndReceiveSingle(Node.STRIP_MUTE, [stripId], []);
  }

  Future<bool> getStripPluginEnable(int stripId, int pluginId) async {
    return await _sendAndReceiveSingle(
        Node.STRIP_PLUGIN_ENABLE, [stripId, pluginId], []);
  }

  Future<dynamic> getStripPluginParamValue(
      int stripId, int pluginId, int paramId) async {
    return await _sendAndReceiveSingle(
        Node.STRIP_PLUGIN_PARAM_VALUE, [stripId, pluginId, paramId], []);
  }

  Future<double> getTempo() async {
    return await _sendAndReceiveSingle(Node.TRANSPORT_TEMPO, [], []);
  }

  Future<bool> getTransportRoll() async {
    return await _sendAndReceiveSingle(Node.TRANSPORT_ROLL, [], []);
  }

  Future<bool> getRecordState() async {
    return await _sendAndReceiveSingle(Node.TRANSPORT_RECORD, [], []);
  }

  void setStripGain(int stripId, double db) {
    this._send(Node.STRIP_GAIN, [stripId], [db]);
  }

  void setStripPan(int stripId, double value) {
    this._send(Node.STRIP_PAN, [stripId], [value]);
  }

  void setStripMute(int stripId, bool value) {
    this._send(Node.STRIP_MUTE, [stripId], [value]);
  }

  void setStripPluginEnable(int stripId, int pluginId, bool value) {
    this._send(Node.STRIP_PLUGIN_ENABLE, [stripId, pluginId], [value]);
  }

  void setStripPluginParamValue(
      int stripId, int pluginId, int paramId, dynamic value) {
    this._send(
        Node.STRIP_PLUGIN_PARAM_VALUE, [stripId, pluginId, paramId], [value]);
  }

  void setTempo(double bpm) {
    this._send(Node.TRANSPORT_TEMPO, [], [bpm]);
  }

  void setTransportRoll(bool value) {
    this._send(Node.TRANSPORT_ROLL, [], [value]);
  }

  void setRecordState(bool value) {
    this._send(Node.TRANSPORT_RECORD, [], [value]);
  }

  Message _send(Node node, List<int> addr, List<dynamic> val) {
    final msg = Message(node, addr, val);
    this._channel.sink.add(msg);
    return msg;
  }

  Future<List<dynamic>> _sendAndReceive(
      Node node, List<int> addr, List<dynamic> val) async {
    final hash = this._send(node, addr, val).nodeAddrHash();
    final respMsg =
        await this.stream.firstWhere((msg) => msg.nodeAddrHash() == hash);
    return respMsg.val;
  }

  Future<dynamic> _sendAndReceiveSingle(
      Node node, List<int> addr, List<dynamic> val) async {
    return (await this._sendAndReceive(node, addr, val))[0];
  }
}
