/*
 * JSONNode.vala
 *
 * The Ambition Web Framework
 * http://www.ambitionframework.org
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace Ambition.Serializer {
	public class Node : Object {
		private Json.Node node;

		public Node( Json.Node node ) {
			this.node = node;
		}

		public Json.Node copy () {
			return node.copy();
		}
		public Json.Array dup_array () {
			return node.dup_array();
		}
		public Json.Object dup_object() {
			return node.dup_object();
		}
		public string dup_string() {
			return node.dup_string();
		}
		public void free() {
			node.free();
		}
		public weak Json.Array get_array() {
			return node.get_array();
		}
		public bool get_boolean() {
			return node.get_boolean();
		}
		public double get_double() {
			return node.get_double();
		}
		public int64 get_int() {
			return node.get_int();
		}
		public Json.NodeType get_node_type() {
			return node.get_node_type();
		}
		public weak Json.Object get_object() {
			return node.get_object();
		}
		public unowned Json.Node get_parent() {
			return node.get_parent();
		}
		public unowned string get_string() {
			return node.get_string();
		}
		public Value get_value() {
			return node.get_value();
		}
		public Type get_value_type() {
			return node.get_value_type();
		}
		public bool is_null() {
			return node.is_null();
		}
		public void set_array(Json.Array array) {
			node.set_array(array);
		}
		public void set_boolean(bool value) {
			node.set_boolean(value);
		}
		public void set_double(double value) {
			node.set_double(value);
		}
		public void set_int(int64 value) {
			node.set_int(value);
		}
		public void set_object(Json.Object object) {
			node.set_object(object);
		}
		public void set_parent(Json.Node parent) {
			node.set_parent(parent);
		}
		public void set_string(string value) {
			node.set_string(value);
		}
		public void set_value(Value value) {
			node.set_value(value);
		}
		public void take_array(owned Json.Array array) {
			node.take_array(array);
		}
		public void take_object(owned Json.Object object) {
			node.take_object(object);
		}
		public unowned string type_name() {
			return node.type_name();
		}
	}
}
