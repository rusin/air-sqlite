package utils
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	public class NestedCreateDatabase
	{
	
		
		
		public function NestedCreateDatabase(dbFile:File=null,encryptionKey:ByteArray = null )
		{
			this.dbFile = dbFile;
			this.encryptionKey = encryptionKey;
		}
		
		
		// ------- Public properties -------
		
		public var dbFile:File;
		public var encryptionKey:ByteArray;
		
		
		// ------- Public methods -------
		
		public function createDatabase():void
		{
			var conn:SQLConnection = new SQLConnection();
			conn.open(dbFile, SQLMode.CREATE, false, 1024, encryptionKey);
			createTable(conn, PARENT_CREATE_TABLE_SQL);
			createTable(conn, CHILD_CREATE_TABLE_SQL);
			conn.close();
		}
						
		// ------- Private methods -------
		
		private function createTable(conn:SQLConnection, sql:String):void
		{
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = conn;
			stmt.text = sql;
			stmt.execute();
		}
				
		// ------- SQL statements -------
		
		[Embed(source="sql/create/CreateTable_parentTestTable.sql", mimeType="application/octet-stream")]
		private static const ParentTableStatementText:Class;
		private static const PARENT_CREATE_TABLE_SQL:String = new ParentTableStatementText();
		
		[Embed(source="sql/create/CreateTable_childTestTable.sql", mimeType="application/octet-stream")]
		private static const ChildTableStatementText:Class;
		private static const CHILD_CREATE_TABLE_SQL:String = new ChildTableStatementText();
	}
}