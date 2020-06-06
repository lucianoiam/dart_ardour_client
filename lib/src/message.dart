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

import 'dart:convert';

class Node {
  static const STRIP_DESCRIPTION              = Node('strip_description');
  static const STRIP_METER                    = Node('strip_meter');
  static const STRIP_GAIN                     = Node('strip_gain');
  static const STRIP_PAN                      = Node('strip_pan');
  static const STRIP_MUTE                     = Node('strip_mute');
  static const STRIP_PLUGIN_DESCRIPTION       = Node('strip_plugin_description');
  static const STRIP_PLUGIN_ENABLE            = Node('strip_plugin_enable');
  static const STRUP_PLUGIN_PARAM_DESCRIPTION = Node('strip_plugin_param_description');
  static const STRIP_PLUGIN_PARAM_VALUE       = Node('strip_plugin_param_value');
  static const TRANSPORT_TEMPO                = Node('transport_tempo');
  static const TRANSPORT_TIME                 = Node('transport_time');
  static const TRANSPORT_ROLL                 = Node('transport_roll');
  static const TRANSPORT_RECORD               = Node('transport_record');
  
  final String _string;

  const Node(this._string);

  String get string => _string;

  operator ==(covariant Node other) => other.string == this.string;

  @override
  int get hashCode => this.string.hashCode;
}

final JSON_INFINITY = double.parse('1.0e+128');

class Message {
  final Node _node;
  final List<int> _addr;
  final List<dynamic> _val;

  const Message(this._node, this._addr, this._val);

  Node get node {
    return _node;
  }

  List<int> get addr {
    return _addr;
  }

  List<dynamic> get val {
    return _val;
  }

  String nodeAddrHash() {
    return this.node.string + '_' + this._addr.join('_');
  }

  String toString() {
    return 'node = ${this.node.string}, addr = ${this.addr}, val = ${this.val}';
  }

  factory Message.fromJson(String data) {
    final msg = jsonDecode(data, reviver: (key, value) {
      if (value is double) {
        if (value >= JSON_INFINITY) {
          return double.infinity;
        } else if (value <= -JSON_INFINITY) {
          return double.negativeInfinity;
        } else {
          return value;
        }
      } else {
        return value;
      }
    });
    return Message(Node(msg['node']), List<int>.from(msg['addr']), msg['val']);
  }

  String toJson() {
    final val = List<dynamic>();
    for (final v in this._val) {
      if (v is double) {
        if (v == double.infinity) {
          val.add(JSON_INFINITY);
        } else if (v == double.negativeInfinity) {
          val.add(-JSON_INFINITY);
        } else {
          val.add(v);
        }
      } else {
        val.add(v);
      }
    }
    final msg = {'node': this._node.string, 'addr': this._addr, 'val': val};
    return jsonEncode(msg);
  }
}
