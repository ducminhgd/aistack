---
name: write-ddd
description: |
  Use this skill when the user is asking for generating Database Design Document from source code or from migrations.
version: 1.0
---
# Write Database Design Document

This skill is used to create or generate the Database Document Design (DDD) base on the source code, or database script,
or migration scripts.

## Rules

1. Determine the framework or programming languague that the current project using.
2. Collect from sources: code files of models, code files or ORMs, database script, or migration script.
3. Don't suggest or don't create any new tables, you responsibility is write a document based on what we having.
4. Describe concisely, shortly for any parts of the document.
5. Naming convention:
  1. When mention a column in the same table, use format: ``[column_name]``.
  2. When mention a column in the other table, use format: ``[table_name].[column_name]``
  2. When mention a column in the other database, use format: ``[db_name].[table_name].[column_name]``

## Knowledge

1. File types: HTML, PDF, Microsoft Word, Markdown, etc. They have _title_, _heading 1_, to _heading 6_.
2. Confluence pages have titles, heading 1 to heading 6, expand element, tab elements.
3. Google Docs: title per tab, heading 1 to heading 6, tabs per file.

## Output rules

There are two types of document output styles, use AskUserQuestion if the user did not mention.

### One document for multiple databases

1. The title SHOULD be "Database Design Document" if the user did not mention.
2. A section with Heading 1 is "Introduction" to go for overview of the file, the databases.
    1. A heading 2 for "How to use" to guide other people or AI Agents how to read, how to contribute to the document
    2. A Heading 2 for "Changes log"
    3. A Heading 2 for "Taxonomies  & Terminologies".
3. Each next Heading 1 is a database.
    1. Each Heading 2 is a table.
        1. A heading 3 for table structure
        2. A heading 3 for contraints or indexes (if any)

### Each file or each page for a database

1. The title SHOULD be "[Database name] Design Document" if the user did not mention.
2. A section with Heading 1 is "Introduction" to go for overview of the file, the databases.
    1. A heading 2 for "How to use" to guide other people or AI Agents how to read, how to contribute to the document
    2. A Heading 2 for "Changes log"
    3. A Heading 2 for "Taxonomies  & Terminologies".
3. Each next Heading 1 is a table.
    1. A heading 2 for table structure
    2. A heading 2 for contraints or indexes (if any)

## Table structure format

When describe a table structure in a database, it is a document table with these columns:

1. Column name: name of the column in databae
    1. If it is a primary key: bold and underline (if feasible).
    2. If it is a uniqueue key: underline (if feasible).
    3. If it is a foreign key: italic (if feasible).
    4. If it is an index: bold (if feasible).
2. Data type: data type of the column, if there is contrainst in data type, add it like `VARCHAR(50)`, or `DECIMAL(20,4)`
3. Descriptions: mention if it is
    1. Nullable? Default value?
    2. Is a Key? Is a Index? Is a foreign key?
    3. Meaning or purpose of the column.
    4. Comment from database.
    5. List available values if it is enums, or just some definitions of values. And their meanings, too.
4. Logic
    1. List the logic where it come from? Is it transformed, and how? List the sustem who use it.
    2. If the logic relates to multiple columns, or complex. Create a new section in this table, same level as "Table structure" to mention the logic of the columns.

Example by markdown

```markdown
| Column | Data Type | Descriptions | Business logic |
| -- | -- | -- | -- |
| **id** | UUID | Primary key | |
```

## Table constraints & indexes

It is a table format, includes these column:

1. Name: name of the indexes
2. Columns: list of the columns in that contraint or index.
3. References: add a list of columns that the field(s) refers to.
4. Descriptions: more information for this index. Why should we have it?

Example by markdown

```markdown
| Name | Columns | References | Descriptions |
| -- | -- | -- | -- |
| | | | |
```