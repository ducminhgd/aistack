---
name: write-ddd
description: |
  Use this skill when the user is asking for generating Database Design Document from source code or from migrations.
version: 1.1
---

# Write Database Design Document

This skill is used to create or generate the Database Document Design (DDD) base on the source code, or database script,
or migration scripts.

## Rules

1. Determine the framework or programming languague that the current project using.
2. Collect from sources by this order: code files of models, code files or ORMs, database script, or migration script.
   1. When there is any removed column, just list it in the table and add "DEPRECATED" on the first line of its
      description, and do not ignore its description.
3. Don't suggest or don't create any new tables, you responsibility is write a document based on what we having.
4. Describe concisely, shortly for any parts of the document.
5. Naming convention:
   1. When mention a column in the same table, use format: `column_name`.
   2. When mention a column in the other table, use format: `table_name.column_name`
   3. When mention a column in the other database, use format: `db_name.table_name.column_name`.
6. In each database table section, you MUST describe the meaning of each record, or whom each record represents for.
7. After creating or updating the document, you need review all the heading and numbering the headings, then update the
   references. Format of the numbering

   ```
   1. Level 1 headings
   1.1. Level 2 headings
   1.1.1. Level 3 headings
   ```

8. Tagging the versions. This is apply for: the document changes log, the migration history, and the table structure.
   And the tags format follows this order:
   1. Git tags.
   2. Git **protected** branches.
      1. Look for those braches if they are exist: `develop`, `dev`, `stg`, `staging`, `production`, `prod`. If yes, it
         is a protected branch, and use it as a tag for the document contents.
   3. Git default branch (`main` or `master`).

9. Colors of tags:
   1. If the tag represents for production, use red color.
   2. If the tag represents for staging, use yellow color.
   3. If the tag represents for development or feature branches, use green color.

## Knowledge

1. File types: HTML, PDF, Microsoft Word, Markdown, etc. They have _title_, _heading 1_, to _heading 6_.
2. Confluence pages have titles, heading 1 to heading 6, expand element, tab elements.
3. Google Docs: title per tab, heading 1 to heading 6, tabs per file.
4. Tags:
   1. Confluence: use the macro `status` to create a tag, and use the color of the status to represent the tag color.
   2. Google Docs: use the element `@DropDown` to create a tag, and use the color of the element to represent the tag
      color.
   3. Markdown: use the text to represent the tag, and make it bold and colored by HTML, like
      `<b style="color:red">v1.0.0</b>`.

## Output rules

There are two types of document output styles, use AskUserQuestion if the user did not mention.

- The first style (_Style 1_) is one document for multiple databases, it is suitable for small projects with few
  databases.
- The second style (_Style 2_) is each file or each page for a database, it is suitable for large projects with many
  databases.

### Structure of the document

#### Introduction

This section is always the first section of the document and it is a Level 1 heading. It is used to describe the
overview of the document, the database (if _Style 2_), and how to use the document. And, it comes with those
sub-sections:

- **How to use**: a Level 2 heading, it is used to guide other people or AI Agents how to read, how to contribute to the
  document.
- **Document changes log**: a Level 2 heading, it is used to describe the changes of the document, who made the change,
  when, and what is changed. It is a table format with these columns: `Version`, `Date`, `Author`, `Changes`. Tags are
  in the `Version` column.
- **Taxonomies & Terminologies**: a Level 2 heading, it is used to describe the taxonomies and terminologies that are
  used in the document, and their meanings.
- **Migration history**: a Level 2 heading, it is used to describe the migration history of the databases, if any. It is
  a table format with these columns: `Migration ID`, `Date`, `Author`, `Description`. Tags are in the `Migration ID`
  column.

#### Database

If the document is _Style 1_, each database is a Level 1 heading, and the format is `Database database_name`. Write the
description of the database, and its purpose. Then, each table is a Level 2 heading, and the format is
`Table table_name`. Write the description of the table, and its purpose.

If the document is _Style 2_, each table is a Level 1 heading, and the format is `Table table_name`. Write the
description of the table, and its purpose.

### Table or view

Style 1: a Level 2 heading.

Style 2: a Level 1 heading.

It describes the purpose of the table or view, and its structure, and the business logic of the table, if any.

#### Table structure

Style 1: a Level 3 heading.

Style 2: a Level 2 heading.

Contains a table format with these columns: `Column`, `Data Type`, `Descriptions`, `Business logic`.

- The `Column` column is the name of the column in the database.
- The `Data Type` column is the data type of the column.
- The `Descriptions` column is used to describe the column, its purpose, and its meaning.
- The `Business logic` column is used to describe the business logic of the column, if any.
- If the column is a primary key, it should be bold and underlined.
- If the column is a unique key, it should be underlined.
- If the column is a foreign key, it should be italic.
- If the column is an index, it should be bold.

#### Table constraints & indexes

Style 1: a Level 3 heading.

Style 2: a Level 2 heading.

It is a table format, includes these column:

1. Name: name of the indexes
2. Columns: list of the columns in that contraint or index.
3. References: add a list of columns that the field(s) refers to.

Example by markdown

```markdown
| Name | Columns | References | Descriptions |
| ---- | ------- | ---------- | ------------ |
|      |         |            |              |
```

#### Data logic

Style 1: a Level 3 heading.

Style 2: a Level 2 heading.

For logic of one or more columns, follow these rules:

1. List the logic where it come from? Is it transformed, and how? List the systems who use it.
2. If the logic relates to multiple columns, or complex. Create a new section in this table, same level as "Table
   structure" to mention the logic of the columns.
