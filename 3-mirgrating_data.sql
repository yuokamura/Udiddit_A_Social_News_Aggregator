/* migrate all the user details */

INSERT INTO "users" ("username")
  SELECT DISTINCT "username"
  FROM "bad_posts";  -- users who have made posts

INSERT INTO "users" ("username")
  SELECT DISTINCT bp."username"
  FROM "bad_comments" bp
    LEFT JOIN "users" u
    ON    bp."username" = u."username"
    WHERE u."username" IS NULL; -- users who have made not made a post

INSERT INTO "users" ("username")
  SELECT DISTINCT tab1."upvote_user"
  FROM  (
        SELECT REGEXP_SPLIT_TO_TABLE("upvotes",',') AS "upvote_user"
        FROM  "bad_posts"
        ) AS tab1
  LEFT JOIN "users" u
  ON     tab1."upvote_user" = u."username"
  WHERE  u."username" IS NULL; -- users who have only upvoted

INSERT INTO "users" ("username")
  SELECT DISTINCT tab1."downvote_user"
  FROM  (
        SELECT REGEXP_SPLIT_TO_TABLE("downvotes",',') AS "downvote_user"
        FROM  "bad_posts"
        ) AS tab1
  LEFT JOIN "users" u
  ON     tab1."downvote_user" = u."username"
  WHERE  u."username" IS NULL; --users who have only downvoted


/* migrate all the topics and respective users */
INSERT INTO "topics" ("name")
  SELECT  DISTINCT  "topic"
  FROM  "bad_posts";


/* migrate posts from bad_posts */
INSERT INTO "posts"
("id","topic_id","user_id","title","url","text_content")
  SELECT  bp."id",
          t."id",
          u."id",
          LEFT(bp."title",100), -- limit title to 100 character max
          bp."url",
          bp."text_content"
  FROM    "bad_posts" bp
    JOIN  "topics" t
    ON    bp."topic" = t."name"
    JOIN  "users" u
    ON    bp."username" = u."username"


/* migrate comments from bad_comments */
INSERT INTO "comments"
("post_id","user_id","text_content")
  SELECT  p."id",
          u."id",
          bc."text_content"
  FROM    "bad_comments" bc
    JOIN  "posts" p
    ON    bc."post_id" = p."id"
    JOIN  "users" u
    ON    bc."username" = u."username";


/* migrate votes */
-- migrate all upvotes as 1
INSERT INTO "votes"
("user_id","post_id","vote")
  SELECT  u."id",
          tab1."post_id",
          1 AS vote
  FROM    (
          SELECT  "id" AS post_id,
                  REGEXP_SPLIT_TO_TABLE(bp."upvotes",',') AS upvote_user
          FROM    "bad_posts" bp
          ) AS tab1
  JOIN  users u
  ON    tab1.upvote_user = u."username";

-- migrate all downvotes as -1
INSERT INTO "votes"
("user_id","post_id","vote")
  SELECT  u."id",
          tab1."post_id",
          -1 AS vote
  FROM    (
          SELECT  "id" AS post_id,
                  REGEXP_SPLIT_TO_TABLE(bp."downvotes",',') AS downvote_user
          FROM    "bad_posts" bp
          ) AS tab1
  JOIN  users u
  ON    tab1.downvote_user = u."username";
