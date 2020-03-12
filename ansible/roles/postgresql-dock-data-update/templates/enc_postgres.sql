CREATE TYPE "enum_Keys_type" AS ENUM ('MASTER','OTHER');
CREATE TABLE "Keys" (
  id SERIAL PRIMARY KEY,
  public text NOT NULL,
  private text NOT NULL,
  type "enum_Keys_type" NOT NULL,
  active boolean DEFAULT true NOT NULL,
  reserved boolean DEFAULT false NOT NULL,
  "createdAt" timestamp with time zone NOT NULL,
  "updatedAt" timestamp with time zone NOT NULL
);
commit;
