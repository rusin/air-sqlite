/**
 * Resolves problem when we want to add in one transaction batch statements which are in parent -> child (master - details) relation. 
 * Import things is that parent's primary keys (after parent statement execution) are set in child's statements.
 * 
 * This class takes nested statemets (tree structure), then transform them to flat structure and using SQLRunner class executes all statements in one transaction
 * 
 * @author rusin, in4mates.com
*/
package com.probertson.data.nested
{
	import com.probertson.data.QueuedStatement;
	import com.probertson.data.SQLRunner;
	
	import flash.data.SQLResult;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	public class SQLNestedStmtRunner
	{
		private var _sqlRunner:SQLRunner;
		
		private var _resultHandler:Function;
		private var _errorHandler:Function;
		
		public function SQLNestedStmtRunner(dbFile:File, resultHandler:Function, errorHandler:Function = null, encryptionKey:ByteArray = null):void{
			this._resultHandler = resultHandler;
			this._errorHandler = errorHandler;
			_sqlRunner = SQLRunner.getInstance(dbFile, encryptionKey);
		}
		
		/**
		 * Executes nestedStatements in one transaction
		 * 
		 * @nestedStatements nested statement tree to execute in one transaction
		 * 
		 **/
		public function executeNestedStatements(nestedStatements:Vector.<NestedStatement>):void {
			if (nestedStatements != null && nestedStatements.length > 0) {
				
				var flatStructure:Vector.<NestedStatement> = new Vector.<NestedStatement>();
				transformNestedStatementsTreeToList(nestedStatements, flatStructure);
				_sqlRunner.executeModifyNS(flatStructure, handleStmtResult, _errorHandler);
			}
		}
		
		/**
		 * Returns nested statements list (tree -> flat list) 
 		 **/
		private function transformNestedStatementsTreeToList(nestedStatements:Vector.<NestedStatement>, list:Vector.<NestedStatement>):void {
			if (list == null) 
				return;
			for each (var ns:NestedStatement in nestedStatements) {
				list.push(ns);
				if (ns.hasNestedStatements()) {
					transformNestedStatementsTreeToList(ns.nestedStatements, list);
				}
			}
		}
		
		/**
		 * Handles sql results (tree -> flat list) 
		 **/		
		private function handleStmtResult( results:Vector.<SQLResult> ):void {
			closeRunner();
		}

		private function closeRunner():void {
			_resultHandler();
		}		
		
//		public function closeRunner():void {
//			_sqlRunner.close(nestedStatExecutorClose);
//		}
//		
//		public function nestedStatExecutorClose():void {
//			trace("SQLRunner has been closed")
//			_resultHandler();
//		}
	}
}