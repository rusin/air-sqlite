/**
 * 
 * @author rusin, in4mates.com
*/
package com.probertson.data.nested
{
	import com.probertson.data.QueuedStatement;
	import com.probertson.data.Responder;
	
	import flash.data.SQLResult;
	import flash.errors.IllegalOperationError;
	
	import mx.collections.ArrayList;
	
	public class NestedStatement extends QueuedStatement
	{
		private var _nestedStatements:Vector.<NestedStatement>;
		private var addParameters:Function;//callback function that are called after statement exection
		private var parameterFilter:Function;
		private var paramPropagation:Boolean;
		
		public function NestedStatement(sql:String, parameters:Object=null, addParameters:Function = null, 
										parameterFilter:Function = null, paramPropagation:Boolean = false)
		{
			super(sql, parameters);
			this.addParameters = addParameters;
			this.parameterFilter = parameterFilter;
			this.paramPropagation = paramPropagation;
		}
		
		public function get nestedStatements():Vector.<NestedStatement> {
			return _nestedStatements;
		}
		
		public function get responder():Responder {
			return new Responder(this.handleExecutionResult);
		}
		
		public function addNestedStatement( nStmt:NestedStatement ):void {
			if (nStmt == null) {
				throw new IllegalOperationError("Nested statement could not be null");
			}
			if (_nestedStatements == null) {
				_nestedStatements = new Vector.<NestedStatement>();
			}
			_nestedStatements.push( nStmt );
		}
		
		public function addNestedStatements( nStmts:Vector.<NestedStatement> ):void {
			if (nStmts != null) {
				for each (var tmp:NestedStatement in nStmts) {
					addNestedStatement(tmp);
				}
			}
 		}
		
		public function setNestedStatements( nStmts:Vector.<NestedStatement> ):void {
			_nestedStatements = nStmts;
		}
		
		public function hasNestedStatements():Boolean {
			return _nestedStatements != null && _nestedStatements.length > 0;
		}
		
		public function handleExecutionResult( rs:SQLResult ):void {
			if (addParameters != null){
				//retrieves pareameters and sets in childs statements
				var obj:Object = addParameters(rs);
				if (obj != null) {
					udpdateNestedStatementsParameters(obj);
				}
			}
		}
		
		protected function udpdateNestedStatementsParameters( paramsToChange:Object ):void {
			if (hasNestedStatements()) {
				//excluding parameters which are redundant
				for (var i:int = 0; i < _nestedStatements.length; i ++) {
					for ( var prop:String in paramsToChange) {
						_nestedStatements[i].changeParameter(prop, paramsToChange[prop]);
					}
				}
			}
		}
		
		public function changeParameter(name:String, value:*):void {
			if (parameterFilter == null || parameterFilter(name)) {
				super.parameters[name] = value;
				if (paramPropagation) {
					var param:Object = new Object();
					param[name] = value;
					udpdateNestedStatementsParameters(param);
				}
			}
		}
		
		public override function get parameters():Object { 
			return super.parameters; 
		}
	}
}