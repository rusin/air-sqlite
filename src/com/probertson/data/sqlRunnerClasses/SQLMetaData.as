/**
 * 
 * @author rusin
 * 
 * This class holds essential information to execute sql statment
 **/
package com.probertson.data.sqlRunnerClasses
{
	import com.probertson.data.Responder;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import org.flexunit.runner.Result;
	
	public class SQLMetaData
	{
		
		public function SQLMetaData(sql:String, stmt:SQLStatement, parameters:Object, responder:Responder)
		{
			_sql = sql;
			_parameters = parameters;
			_responder = responder;
			_stmt = stmt;
		}
		
		// ------- Public properties -------
		
		private var _sql:String;
		
		public function get sql():String
		{
			return _sql;
		}
		
		private var _stmt:SQLStatement;
		
		public function get stmt():SQLStatement
		{
			return _stmt;
		}
		
		private var _parameters:Object;
		
		public function get parameters():Object
		{
			return _parameters;
		}
		
		private var _responder:Responder;
		
		public function get responder():Responder
		{
			return _responder;
		}
		
		private var _rs:SQLResult;
		
		public function get result():SQLResult
		{
			return _rs;
		}
		
		public function set result(value:SQLResult):void
		{
			if (responder != null) {
				//used to populate result
				responder.result(value);
			}
			_rs = value;
		}
	}
}