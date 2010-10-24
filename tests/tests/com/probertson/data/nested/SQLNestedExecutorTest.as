package tests.com.probertson.data.nested
{
	import com.adobe.data.encryption.EncryptionKeyGenerator;
	import com.dehats.air.sqlite.SimpleEncryptionKeyGenerator;
	import com.probertson.data.QueuedStatement;
	import com.probertson.data.SQLRunner;
	import com.probertson.data.nested.NestedStatement;
	import com.probertson.data.nested.SQLNestedStmtRunner;
	
	import events.ExecuteModifyErrorEvent;
	import events.ExecuteModifyResultEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import flexunit.framework.Assert;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.async.Async;
	
	import utils.NestedCreateDatabase;

	
	public class SQLNestedExecutorTest extends EventDispatcher
	{
		// Reference declaration for class to test
		private var _sqlRunner:SQLRunner;
		
		// Reference declaration for class to test
		private var _sqlNestedQueryExecution:SQLNestedStmtRunner;
		
		private static var DB_PASSWORD: String = "Password";
		// ------- Instance vars -------
		
		private var _dbFile:File;
		
		
		// ------- Setup/cleanup -------
		
		[Before]
		public function setUp():void
		{
			_dbFile = File.createTempDirectory().resolvePath("test.db");
			var createDB:NestedCreateDatabase = new NestedCreateDatabase(_dbFile, getEncryptionKey(DB_PASSWORD, _dbFile));
			createDB.createDatabase();
		}
		
		private function getEncryptionKey(password:String, _dbFile:File):ByteArray  
		{  
			return new SimpleEncryptionKeyGenerator().getEncryptionKey(password);
		}
		
		[After(async, timeout="30001")]
		public function tearDown():void
		{
			_sqlNestedQueryExecution = null;
			var tempDir:File = _dbFile.parent;
			tempDir.deleteDirectory(true);
		}
		
		// ------- Tests -------
		
		[Test(async, timeout="5000")]
		public function testOneStatement():void
		{
			addEventListener(ExecuteModifyResultEvent.RESULT, Async.asyncHandler(this, testOneStatement_result, 5000));
			
			var nestedStatments:Vector.<NestedStatement> = new Vector.<NestedStatement>;
			var stmtParent:NestedStatement;
			stmtParent = getParentNestedStatement();//creates nested statement parent 
			stmtParent.addNestedStatement(getChildNestedStatement());//add child which will have parent id set after parent statement execution
			stmtParent.addNestedStatement(getChildNestedStatement());//add child which will have parent id set after parent statement execution
			nestedStatments.push(stmtParent);//adds parent to nested statements
			stmtParent = getParentNestedStatement();
			stmtParent.addNestedStatement(getChildNestedStatement());
			stmtParent.addNestedStatement(getChildNestedStatement());
			nestedStatments.push(stmtParent);//adds parent to nested statements
			
			_sqlNestedQueryExecution = new SQLNestedStmtRunner(_dbFile,testOneStatement_result2, testOneStatement_error, getEncryptionKey(DB_PASSWORD, _dbFile));
			_sqlNestedQueryExecution.executeNestedStatements(nestedStatments);
		}
		
//		[Test(async, timeout="30000")]
//		public function testOneStatement2():void
//		{
//			addEventListener(ExecuteModifyResultEvent.RESULT, Async.asyncHandler(this, testOneStatement_result, 30000));
//			
//			var nestedStatments:Vector.<NestedStatement> = new Vector.<NestedStatement>;
//			for (var l:int = 0; l < 10; l++) {
//				var parent:NestedStatement = getParentNestedStatement();nestedStatments.push(parent);
//				var tmpStmt:NestedStatement;
//				for (var k:int = 1; k < 10; k++) {	
//					for (var i:int = 0; i < 1000; i++) {
//						tmpStmt = getChildNestedStatement();
//						parent.addNestedStatement(tmpStmt);
//					}
//					parent = tmpStmt;
//				}
//			}
//			
//			_sqlNestedQueryExecution = new SQLNestedStmtRunner(_dbFile,testOneStatement_result2, testOneStatement_error, getEncryptionKey(DB_PASSWORD, _dbFile));
//			_sqlNestedQueryExecution.executeNestedStatements(nestedStatments);
//		}
		
		private function getParentNestedStatement():NestedStatement {
			var stmt:NestedStatement;
			//return parameters which are set in children statements
			var addParameters:Function = function addParameters( rs:SQLResult ):Object {
				var oid:int = rs.lastInsertRowID;
				return {childParentId:oid};
			}
			stmt = new NestedStatement(ADD_PARENT_ROW_SQL, {parentColString:"testParent", parentColInt:1}, addParameters);
			return stmt;
		}
		
		private function getChildNestedStatement():NestedStatement {
			var stmt:NestedStatement;
			var addParameters:Function = function addParameters( rs:SQLResult ):Object {
				var oid:int = rs.lastInsertRowID;
				return {childParentId:oid};
			}				
			stmt = new NestedStatement(ADD_CHILD_ROW_SQL, {childColString:"testChild"},addParameters);
			return stmt;
		}
		
		// --- handlers ---
		
		private function testOneStatement_result2():void
		{
			dispatchEvent(new ExecuteModifyResultEvent(ExecuteModifyResultEvent.RESULT, new Vector.<SQLResult>()));
		}
		
		private function testOneStatement_result(event:ExecuteModifyResultEvent, passThroughData:Object):void
		{
			trace("Success...");
		}
		
		private function testOneStatement_error(error:SQLError):void
		{
			trace(error.getStackTrace());
			Assert.fail(error.message);
		}
		
		// ------- SQL statements -------
		
		[Embed(source="sql/ParentAddRow.sql", mimeType="application/octet-stream")]
		private static const AddParentRowStatementText:Class;
		private static const ADD_PARENT_ROW_SQL:String = new AddParentRowStatementText();
		
		// ------- SQL statements -------
		
		[Embed(source="sql/ChildAddRow.sql", mimeType="application/octet-stream")]
		private static const AddChildRowStatementText:Class;
		private static const ADD_CHILD_ROW_SQL:String = new AddChildRowStatementText();
	}
}