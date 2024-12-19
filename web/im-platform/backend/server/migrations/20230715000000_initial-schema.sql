-- 数据库初始方案

CREATE TABLE IF NOT EXISTS "users"
(
    "id" BIGINT PRIMARY KEY,
    "username" TEXT NOT NULL UNIQUE,
    "display_name" TEXT NOT NULL,
    "last_presence" SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "secrets"
(
    "user_id" BIGINT PRIMARY KEY REFERENCES "users"("id") ON DELETE CASCADE,
    "password" TEXT NOT NULL,
    "is_valid" BOOLEAN NOT NULL DEFAULT TRUE,
    "last_changed" BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "guilds"
(
    "id" BIGINT PRIMARY KEY,
    "owner_id" BIGINT NOT NULL REFERENCES "users" ("id") ON DELETE CASCADE,
    "name" TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS "members"
(
    "user_id" BIGINT NOT NULL REFERENCES "users" ("id") ON DELETE CASCADE,
    "guild_id" BIGINT NOT NULL REFERENCES "guilds" ("id") ON DELETE CASCADE,
    "joined_at" BIGINT NOT NULL,
    PRIMARY KEY ("user_id", "guild_id")
);

DROP TABLE IF EXISTS "messages";

CREATE TABLE "messages"
(
    "id" BIGINT PRIMARY KEY,
    "user_id" BIGINT REFERENCES "users" ("id") ON DELETE SET NULL,
    "guild_id" BIGINT NOT NULL REFERENCES "guilds" ("id") ON DELETE CASCADE,
    "content" TEXT NOT NULL
);
