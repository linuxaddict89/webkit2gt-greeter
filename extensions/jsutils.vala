/*
 * Copyright 2011-2018 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
using JS;
using Luminos.Utility;

namespace Luminos.JSUtils {
/**
 * Converts JavaScriptCore string to Vala UTF-8 string
 *
 * @param jsstring JavaScriptCore string
 * @return Vala UTF-8 string
 */
	public static string utf8_string(JS.String jsstring) {
		size_t max_size = jsstring.get_maximum_utf8_string_size();
		uint8[] buffer = new uint8[max_size];
		jsstring.get_utf8_string(buffer);
		return (string) buffer;
	}

/**
 * Creates JavaScript object from JSON.
 *
 * @param ctx   JavaScript context
 * @param json  object in JSON notation
 * @return  JavaScript object
 */
	public unowned JS.Value object_from_JSON(JS.Context ctx, string json) {
		unowned JS.Value ? result = JS.Value.from_JSON(ctx, new JS.String(json == "" ? "{}" : json));
		if(result == null || !result.is_object(ctx)) {
			result = ctx.make_object(null, null);
		}
		return result;
	}

/**
 * Creates JavaScript Exception object.
 *
 * @param ctx   JavaScript context
 * @param message   Error message (single line);
 * @return  JavaScript object
 */
	public unowned JS.Value create_exception(JS.Context ctx, string message) {
		string exception = """{"type":"NuvolaError", "message":"%s"}""".printf(message.replace("\"", "\\\""));
		debug(exception);
		return object_from_JSON(ctx, exception);
	}

/**
 * Obtains string property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @return string value or null if property is not a string
 */
	public static string? o_get_string(Context ctx, JS.Object obj, string property) {
		unowned JS.Value value = obj.get_property(ctx, new JS.String(property));
		if(value.is_string(ctx)) {
			return utf8_string(value.to_jsstring(ctx));
		}
		return null;
	}

/**
 * Obtains number property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @return double value or 0.0 if property is not a number
 */
	public static double o_get_number(Context ctx, JS.Object obj, string property) {
		unowned JS.Value value = obj.get_property(ctx, new JS.String(property));
		if(value.is_number(ctx)) {
			return value.to_number(ctx);
		}
		return 0.0;
	}

/**
 * Sets string property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @param value property value
 */
	public static void o_set_string(Context ctx, JS.Object obj, string property, string value) {
		obj.set_property(ctx, new JS.String(property), JS.Value.string(ctx, new JS.String(value)));
	}

/**
 * Sets string property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @param value property value
 */
	public static void o_set_number(Context ctx, JS.Object obj, string property, double value) {
		obj.set_property(ctx, new JS.String(property), JS.Value.number(ctx, value));
	}

/**
 * Sets null property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 */
	public static void o_set_null(Context ctx, JS.Object obj, string property) {
		obj.set_property(ctx, new JS.String(property), JS.Value.null(ctx));
	}

/**
 * Sets boolean property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @param value property value
 */
	public static void o_set_bool(Context ctx, JS.Object obj, string property, bool value) {
		obj.set_property(ctx, new JS.String(property), JS.Value.boolean(ctx, value));
	}

/**
 * Obtains object property of JavaScript object
 *
 * @param ctx JavaScript context
 * @param obj JavaScript object
 * @param property property name
 * @return object or null if property is not a object
 */
	public static unowned JS.Object ? o_get_object(Context ctx, JS.Object obj, string property) {
		unowned JS.Value value = obj.get_property(ctx, new JS.String(property));
		if(value.is_object(ctx)) {
			return value.to_object(ctx);
		}
		return null;
	}

/**
 * Converts JavaScript value to string
 *
 * @param ctx            JavaScript context
 * @param val            JavaScript value
 * @param allow_empty    if false null will be returned for empty string
 * @return string value or null if value is not a string
 */
	public static string? string_or_null(JS.Context ctx, JS.Value val, bool allow_empty = false) {
		if(val.is_string(ctx)) {
			string str = utf8_string(val.to_jsstring(ctx));
			return (str == "" && !allow_empty) ? null : str;
		}
		return null;
	}

	public string? value_to_string(JS.Context ctx, JS.Value value) {
		if(value.is_string(ctx)) {
			return utf8_string(value.to_jsstring(ctx));
		}
		if(value.is_number(ctx)) {
			return (value.to_number(ctx).to_string());
		}
		if(value.is_object(ctx)) {
			return utf8_string(value.to_object(ctx).to_JSON(ctx, 0, null));
		}
		return null;
	}

	public string? exception_to_string(JS.Context ctx, JS.Value value) {
		if(value.is_object(ctx)) {
			unowned JS.Object obj = value.to_object(ctx);
			string? message = o_get_string(ctx, obj, "message");
			if(message != null) {
				string? name = o_get_string(ctx, obj, "name");
				var line = (int) o_get_number(ctx, obj, "line");
				string? file = o_get_string(ctx, obj, "sourceURL");
				if(line == 0 && file == null) {
					return "%s: %s. Enable JS debugging for more details.".printf(name ?? "null", message);
				}
				return "%s:%d: %s: %s".printf(file ?? "(null)", line, name ?? "null", message);
			}
		}
		return value_to_string(ctx, value);
	}

	public unowned JS.Value get_gobject_property_named(JS.Context ctx, GLib.Object o, string name) {
		ObjectClass klass = (ObjectClass) o.get_type().class_ref();
		unowned ParamSpec ? p = klass.find_property(name);
		if(p == null) {
			return JS.Value.undefined(ctx);
		}
		return get_gobject_property(ctx, o, p);
	}

	public unowned JS.Value get_gobject_property(JS.Context ctx, GLib.Object o, ParamSpec p) {
		GLib.Type type = p.value_type;
		if(type == typeof(string)) {
			string str_val;
			o.@get(p.name, out str_val);
			return JS.Value.string(ctx, new JS.String(str_val));
		}

		if(type == typeof(int)) {
			int int_val;
			o.@get(p.name, out int_val);
			return JS.Value.number(ctx, (double) int_val);
		}

		if(type == typeof(float)) {
			float float_val;
			o.@get(p.name, out float_val);
			return JS.Value.number(ctx, (double) float_val);
		}

		if(type == typeof(double)) {
			double double_val;
			o.@get(p.name, out double_val);
			return JS.Value.number(ctx, (double) double_val);
		}

		if(type == typeof(bool)) {
			bool bool_val;
			o.@get(p.name, out bool_val);
			return JS.Value.boolean(ctx, bool_val);
		}

		return JS.Value.undefined(ctx);
	}

	public unowned JS.Value value_from_variant(JS.Context ctx, Variant? variant) throws JSApiError {
		if(variant == null) {
			return JS.Value.null(ctx);
		}

		VariantType type = variant.get_type();

		if(variant.is_of_type(VariantType.VARIANT)) {
			return value_from_variant(ctx, variant.get_variant());
		}

		if(type.is_subtype_of(VariantType.MAYBE)) {
			Variant ? maybe_variant = null;
			variant.get("m*", &maybe_variant);
			if(maybe_variant == null) {
				return JS.Value.null(ctx);
			}
			return value_from_variant(ctx, maybe_variant);
		}

		var object_type = new VariantType("a{s*}");
		if(type.is_subtype_of(object_type)) {
			unowned JS.Object object = ctx.make_object();
			VariantIter iter = null;
			variant.get("a{s*}", &iter);
			string key = null;
			Variant value = null;
			while(iter.next("{s*}", &key, &value)) {
				object.set_property(ctx, new JS.String(key), value_from_variant(ctx, value));
			}
			return object;
		}

		if(variant.is_of_type(VariantType.STRING)) {
			return JS.Value.string(ctx, new JS.String(variant.get_string()));
		}

		if(variant.is_of_type(VariantType.BOOLEAN)) {
			return JS.Value.boolean(ctx, variant.get_boolean());
		}

		if(variant.is_of_type(VariantType.DOUBLE)) {
			return JS.Value.number(ctx, variant.get_double());
		}

		if(variant.is_of_type(VariantType.INT32)) {
			return JS.Value.number(ctx, (double) variant.get_int32());
		}

		if(variant.is_of_type(VariantType.UINT32)) {
			return JS.Value.number(ctx, (double) variant.get_uint32());
		}

		if(variant.is_of_type(VariantType.INT64)) {
			return JS.Value.number(ctx, (double) variant.get_int64());
		}

		if(variant.is_of_type(VariantType.UINT64)) {
			return JS.Value.number(ctx, (double) variant.get_uint64());
		}

		if(variant.is_container()) {
			size_t size = variant.n_children();
			void*[] args = new void*[size];
			for(var i = 0; i < size; i++) {
				args[i] = (void*) value_from_variant(ctx, variant.get_child_value(i));
			}
			return ctx.make_array((JS.Value[])args);
		}

		throw new JSApiError.WRONG_TYPE("Unsupported type '%s'. Content: %s", variant.get_type_string(), variant.print(true));
	}

	public Variant variant_from_value(JS.Context ctx, JS.Value val) throws JSApiError {
		if(val.is_null(ctx)) {
			return new Variant("mv", null);
		}

		if(val.is_string(ctx)) {
			return new Variant.string(utf8_string(val.to_jsstring(ctx)));
		}

		if(val.is_number(ctx)) {
			return new Variant.double(val.to_number(ctx));
		}

		if(val.is_boolean(ctx)) {
			return new Variant.boolean(val.to_boolean(ctx));
		}

		unowned JS.Object object;

		if(is_js_array(ctx, val)) {
			VariantBuilder builder = new VariantBuilder(new VariantType("av"));
			object = (JS.Object)val;
			int size = (int) o_get_number(ctx, object, "length");
			for(uint i = 0; i < size; i++) {
				builder.add("v", variant_from_value(ctx, object.get_property_at_index(ctx, i)));
			}

			return builder.end();
		}

		if(val.is_object(ctx)) {
			object = (JS.Object)val;
			JS.Properties properties = object.get_properties(ctx);
			size_t size = properties.get_count();
			var builder = new VariantBuilder(new VariantType("a{smv}"));
			for(size_t i = 0; i < size; i++) {
				unowned JS.String js_property = properties.get(i);
				Variant? value = variant_from_value(ctx, object.get_property(ctx, js_property));
				builder.add("{smv}", utf8_string(js_property), value);
			}

			return builder.end();
		}
		throw new JSApiError.WRONG_TYPE("Attempt to convert ` undefined ` JavaScript type .");
		//  return new Variant.string("<ERROR: UNDEFINED VALUE TYPE>");
	}
	public static bool is_null_or_undefined(JS.Context ctx, JS.Value value) {
		return value.is_null(ctx) || value.is_undefined(ctx);
	}
	public static bool is_defined(JS.Context ctx, JS.Value value) {
		return !value.is_null(ctx) && !value.is_undefined(ctx);
	}

	public unowned JS.Object remove_property(JS.Context ctx, JS.Object obj, string key) {
		message("remove_property called to remove property %s", key);
		unowned JS.Object newObj = ctx.make_object();
		string[] propertyNames = get_property_names(ctx, obj);
		message("propertyNames : %s", array_string_to_string(propertyNames));
		for(var i = 0; i < propertyNames.length; i++) {
			string name = propertyNames[i];
			if(name != key) {
				unowned JS.Value val = obj.get_property(ctx, new JS.String(name));
				if(!is_null_or_undefined(ctx, val)) {
					newObj.set_property(ctx, new JS.String(name), val);
				}
			}
		}
		string[] newPropertyNames = get_property_names(ctx, newObj);
		message("new propertyNames : %s", array_string_to_string(newPropertyNames));
		return newObj;
	}
	public static unowned JS.Value get_js_property_names(JS.Context ctx, JS.Value value) {
		if(value.is_object(ctx)) {
			JS.Value? exception;
			JS.String name = new JS.String.with_utf8_c_string("Object");
			unowned JS.Object global_obj = ctx.get_global_object();
			unowned JS.Object obj = global_obj.get_property(ctx, name).to_object(ctx);

			name = new JS.String.with_utf8_c_string("getOwnPropertyNames");
			unowned JS.Object getOwnPropertyNames = obj.get_property(ctx, name).to_object(ctx);

			// create new arguments to be used when calling getOwnPropertyNames function
			void*[] params = new void*[1];
			params[0] = (void*) value;
			message("calling getOwnPropertyNames");
			unowned JS.Value retval = getOwnPropertyNames.call_as_function(ctx, obj, (JS.Value[]) params, out exception);
			if(!retval.is_undefined(ctx) && !retval.is_null(ctx)) {
				message("returning value : %s", is_js_array(ctx, retval).to_string());
				return retval;
			}

		}
		return JS.Value.undefined(ctx);
	}

	public static string[]? get_property_names(JS.Context ctx, JS.Value value) {
		if(value.is_object(ctx)) {
			JS.Value? exception;
			JS.String name = new JS.String.with_utf8_c_string("Object");
			unowned JS.Object global_obj = ctx.get_global_object();
			unowned JS.Object obj = global_obj.get_property(ctx, name).to_object(ctx);

			name = new JS.String.with_utf8_c_string("getOwnPropertyNames");
			unowned JS.Object getOwnPropertyNames = obj.get_property(ctx, name).to_object(ctx);

			// create new arguments to be used when calling getOwnPropertyNames function
			void*[] params = new void*[1];
			params[0] = (void*) value;

			unowned JS.Object retval = (JS.Object)getOwnPropertyNames.call_as_function(ctx, obj, (JS.Value[]) params, out exception);
			int size = (int) o_get_number(ctx, retval, "length");
			string[] results = new string[size];

			for(uint i = 0; i < size; i++) {
				results[i] = value_to_string(ctx, retval.get_property_at_index(ctx, i));
			}
			return results;
		}
		return null;
	}

	public static bool is_js_array(JS.Context ctx, JS.Value value) {
		if(value.is_object(ctx)) {
			JS.Value? exception;
			JS.String name = new JS.String.with_utf8_c_string("Array");
			unowned JS.Object global_obj = ctx.get_global_object();
			unowned JS.Object array = global_obj.get_property(ctx, name).to_object(ctx);

			name = new JS.String.with_utf8_c_string("isArray");
			unowned JS.Object isArray = array.get_property(ctx, name).to_object(ctx);

			// create new arguments to be used when calling isArray function
			void*[] params = new void*[1];
			params[0] = (void*) value;

			unowned JS.Value retval = isArray.call_as_function(ctx, array, (JS.Value[]) params, out exception);

			message("restrieved value : %s", retval.to_boolean(ctx).to_string());
			if(retval.is_boolean(ctx))
				return retval.to_boolean(ctx);
		}
		return false;
	}
	public static unowned JS.Value to_js_string(JS.Context ctx, string val) {
		return JS.Value.string(ctx, new JS.String(val));
	}

	public static bool has_property(JS.Context ctx, JS.Object obj, string name) {
		unowned JS.Value val = obj.get_property(ctx, new JS.String(name));
		return !val.is_null(ctx) && !val.is_undefined(ctx);
	}

	public errordomain JSApiError {
		ERROR,
		/**
		 * An object has not been found
		 */
		NOT_FOUND,
		/**
		 * A value has wrong type
		 */
		WRONG_TYPE,
		/**
		 * Call of a JavaScript function failed.
		 */
		FUNC_FAILED,
		/**
		 * Unable to load script from file
		 */
		READ_ERROR,
		/**
		 * JavaScript API does not have any context yet.
		 */
		NO_CONTEXT,
		/**
		 * Execution of a script caused an exception.
		 */
		EXCEPTION,

		INITIALIZATION_FAILED;
	}
} // namespace Nuvola.JSTools
