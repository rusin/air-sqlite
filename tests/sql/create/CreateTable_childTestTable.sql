CREATE TABLE main.childTestTable
(
	childColIntPK int PRIMARY KEY AUTOINCREMENT,
	childColString String NOT NULL,
	childParentId INTEGER NOT NULL,
        FOREIGN KEY(childParentId) REFERENCES parentTestTable(parentColIntPK)
)
