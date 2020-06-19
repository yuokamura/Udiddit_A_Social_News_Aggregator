-- building schema

CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(25) UNIQUE NOT NULL,
  "last_log_in" TIMESTAMP WITH TIME ZONE
);
CREATE INDEX "last_log_in" ON "users" ("last_log_in"); -- 2.a
CREATE INDEX "find_username_pattern_matching"
ON "users" ("username" VARCHAR_Pattern_OPS); --2.c
--2.b users.id is pk so no indexing required


CREATE TABLE "topics" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(30) UNIQUE NOT NULL,
  "description" VARCHAR(500)
);
CREATE INDEX "find_topic_pattern_matching"
ON "topics" ("name" VARCHAR_Pattern_OPS); -- 2.e
-- 2.d topics.id is pk so no indexing required


CREATE TABLE "posts" (
  "id" SERIAL PRIMARY KEY,
  "topic_id" INTEGER REFERENCES "topics" ON DELETE CASCADE,
  "user_id" INTEGER REFERENCES "users" ON DELETE SET NULL,
  "post_date" TIMESTAMP WITH TIME ZONE,
  "title" VARCHAR(100) NOT NULL,
  "url" VARCHAR(4000) DEFAULT NULL,
  "text_content" TEXT DEFAULT NULL,
  CHECK ("url" IS NULL AND "text_content" IS NOT NULL
        OR "url" IS NOT NULL AND "text_content" IS NULL)
);
CREATE INDEX "find_latest_post_per_topic"
ON "posts" ("topic_id","post_date"); -- 2.f
CREATE INDEX "find_latest_post_per_user"
ON "posts" ("user_id","post_date"); -- 2.g
CREATE INDEX "find_url_pattern_matching"
ON "posts" ("url" VARCHAR_Pattern_OPS); --2.h


CREATE TABLE "comments" (
  "id" SERIAL PRIMARY KEY,
  "post_id" INTEGER REFERENCES "posts" ON DELETE CASCADE,
  "user_id" INTEGER REFERENCES "users" ON DELETE SET NULL,
  "comment_date" TIMESTAMP WITH TIME ZONE,
  "text_content" TEXT NOT NULL,
  "parent_id" INTEGER DEFAULT NULL,
  "level" INTEGER DEFAULT 1,
  FOREIGN KEY ("parent_id") REFERENCES "comments" ON DELETE CASCADE,
  -- allows the thread system.
  CHECK ("level">=1)
);
CREATE INDEX "find_parent_or_its_child_comment"
ON "comments" ("parent_id"); -- 2.i and 2.j
CREATE INDEX "find_latest_comment_per_user"
ON "comments" ("user_id","comment_date"); -- 2.k


CREATE TABLE "votes" (
  "user_id" INTEGER REFERENCES "users" ON DELETE SET NULL,
  "post_id" INTEGER REFERENCES "posts" ON DELETE CASCADE,
  "vote" INTEGER CHECK("vote" = 1 OR "vote"=-1),
  PRIMARY KEY ("post_id","user_id")
);
CREATE INDEX "scoring_post"
ON "votes" ("vote"); -- 2.l
