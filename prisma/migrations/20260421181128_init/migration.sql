-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "postgis";

-- CreateTable
CREATE TABLE "technological_cards" (
    "id" BIGSERIAL NOT NULL,
    "enterprise_id" BIGINT NOT NULL,
    "variety_id" BIGINT NOT NULL,
    "planting_density" INTEGER NOT NULL,
    "planting_norm_per_ha" DOUBLE PRECISION NOT NULL,
    "planned_yield" DECIMAL(65,30) NOT NULL,
    "growth_duration_days" INTEGER,
    "applied_seed_weight" DECIMAL(65,30),
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "technological_cards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plantings" (
    "id" BIGSERIAL NOT NULL,
    "tc_id" BIGINT,
    "start_date" TIMESTAMPTZ(6) NOT NULL,
    "end_date" TIMESTAMPTZ(6) NOT NULL,
    "planting_norm_snapshot_thousands" DECIMAL(65,30),
    "area_ha" DECIMAL(65,30),
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "plantings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "planting_greenhouse_blocks" (
    "id" SERIAL NOT NULL,
    "seeding_id" BIGINT NOT NULL,
    "block_id" BIGINT,

    CONSTRAINT "planting_greenhouse_blocks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" BIGSERIAL NOT NULL,
    "first_name" VARCHAR(128) NOT NULL DEFAULT '',
    "last_name" VARCHAR(128) NOT NULL DEFAULT '',
    "email" VARCHAR(256) NOT NULL,
    "hash" VARCHAR(256) NOT NULL,
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_role_assignments" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "user_role_id" BIGINT NOT NULL,
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_role_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" BIGSERIAL NOT NULL,
    "role_name" VARCHAR(64) NOT NULL,
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" BIGSERIAL NOT NULL,
    "user_id" BIGINT NOT NULL,
    "refresh_token_hash" TEXT,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enterprises" (
    "id" BIGSERIAL NOT NULL,
    "enterprise_name" VARCHAR(128) NOT NULL,
    "shape" geometry(Polygon, 4326),
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "enterprises_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enterprise_owners" (
    "id" BIGSERIAL NOT NULL,
    "enterprise_id" BIGINT NOT NULL,
    "user_owner_id" BIGINT NOT NULL,

    CONSTRAINT "enterprise_owners_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "enterprise_members" (
    "id" BIGSERIAL NOT NULL,
    "enterprise_id" BIGINT NOT NULL,
    "user_member_id" BIGINT NOT NULL,

    CONSTRAINT "enterprise_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "greenhouse_blocks" (
    "id" BIGSERIAL NOT NULL,
    "enterprise_id" BIGINT NOT NULL,
    "soil_id" BIGINT,
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "greenhouse_blocks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "greenhouses" (
    "id" BIGSERIAL NOT NULL,
    "gh_block_id" BIGINT,
    "gh_shape_type_id" BIGINT NOT NULL,
    "gh_material_id" BIGINT NOT NULL,
    "has_artificial_lights" BOOLEAN NOT NULL,
    "has_ventilation" BOOLEAN NOT NULL,
    "shape" geometry(Polygon, 4326),
    "deleted_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "greenhouses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "greenhouse_materials" (
    "id" BIGSERIAL NOT NULL,
    "material_name" VARCHAR(128) NOT NULL,

    CONSTRAINT "greenhouse_materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "greenhouse_shapes" (
    "id" BIGSERIAL NOT NULL,
    "gh_shape_name" VARCHAR(128) NOT NULL,
    "is_extensible" BOOLEAN NOT NULL,

    CONSTRAINT "greenhouse_shapes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "soils" (
    "id" BIGSERIAL NOT NULL,
    "soil_name" VARCHAR(128) NOT NULL,
    "soil_bulk_density" DOUBLE PRECISION NOT NULL,
    "soil_porosity" DOUBLE PRECISION NOT NULL,
    "soil_layer_specific_mass" DOUBLE PRECISION NOT NULL,
    "soil_field_capacity" DOUBLE PRECISION NOT NULL,
    "soil_acidity" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "soils_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "varieties" (
    "id" BIGSERIAL NOT NULL,
    "crop_id" BIGINT NOT NULL,
    "variety_name" VARCHAR(128),
    "weight_1000_seeds" DECIMAL(65,30) NOT NULL,
    "growth_factor" DECIMAL(65,30) NOT NULL,

    CONSTRAINT "varieties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "crops" (
    "id" BIGSERIAL NOT NULL,
    "crop_name" VARCHAR(128) NOT NULL,

    CONSTRAINT "crops_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "culture_soil_recommendations" (
    "id" BIGSERIAL NOT NULL,
    "crop_id" BIGINT NOT NULL,
    "soil_id" BIGINT NOT NULL,

    CONSTRAINT "culture_soil_recommendations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "technological_cards_enterprise_id_idx" ON "technological_cards"("enterprise_id");

-- CreateIndex
CREATE INDEX "technological_cards_variety_id_idx" ON "technological_cards"("variety_id");

-- CreateIndex
CREATE INDEX "plantings_tc_id_idx" ON "plantings"("tc_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "email_unique" ON "users"("email");

-- CreateIndex
CREATE INDEX "user_role_assignments_user_id_user_role_id_idx" ON "user_role_assignments"("user_id", "user_role_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_role_assignments_user_id_user_role_id_key" ON "user_role_assignments"("user_id", "user_role_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_roles_role_name_key" ON "user_roles"("role_name");

-- CreateIndex
CREATE UNIQUE INDEX "enterprises_enterprise_name_key" ON "enterprises"("enterprise_name");

-- CreateIndex
CREATE UNIQUE INDEX "enterprises_id_enterprise_name_key" ON "enterprises"("id", "enterprise_name");

-- CreateIndex
CREATE INDEX "enterprise_owners_user_owner_id_idx" ON "enterprise_owners"("user_owner_id");

-- CreateIndex
CREATE INDEX "enterprise_owners_enterprise_id_idx" ON "enterprise_owners"("enterprise_id");

-- CreateIndex
CREATE INDEX "enterprise_members_user_member_id_idx" ON "enterprise_members"("user_member_id");

-- CreateIndex
CREATE INDEX "enterprise_members_enterprise_id_idx" ON "enterprise_members"("enterprise_id");

-- CreateIndex
CREATE INDEX "greenhouses_gh_block_id_idx" ON "greenhouses"("gh_block_id");

-- CreateIndex
CREATE INDEX "greenhouses_gh_shape_type_id_idx" ON "greenhouses"("gh_shape_type_id");

-- CreateIndex
CREATE INDEX "greenhouses_gh_material_id_idx" ON "greenhouses"("gh_material_id");

-- CreateIndex
CREATE INDEX "greenhouses_has_artificial_lights_idx" ON "greenhouses"("has_artificial_lights");

-- CreateIndex
CREATE INDEX "greenhouses_has_ventilation_idx" ON "greenhouses"("has_ventilation");

-- CreateIndex
CREATE UNIQUE INDEX "greenhouse_materials_material_name_key" ON "greenhouse_materials"("material_name");

-- CreateIndex
CREATE UNIQUE INDEX "greenhouse_materials_id_material_name_key" ON "greenhouse_materials"("id", "material_name");

-- CreateIndex
CREATE UNIQUE INDEX "greenhouse_shapes_gh_shape_name_key" ON "greenhouse_shapes"("gh_shape_name");

-- CreateIndex
CREATE INDEX "greenhouse_shapes_is_extensible_idx" ON "greenhouse_shapes"("is_extensible");

-- CreateIndex
CREATE UNIQUE INDEX "soils_soil_name_key" ON "soils"("soil_name");

-- CreateIndex
CREATE UNIQUE INDEX "soils_id_soil_name_key" ON "soils"("id", "soil_name");

-- CreateIndex
CREATE INDEX "varieties_crop_id_idx" ON "varieties"("crop_id");

-- CreateIndex
CREATE UNIQUE INDEX "crops_crop_name_key" ON "crops"("crop_name");

-- CreateIndex
CREATE UNIQUE INDEX "crops_id_crop_name_key" ON "crops"("id", "crop_name");

-- AddForeignKey
ALTER TABLE "technological_cards" ADD CONSTRAINT "technological_cards_enterprise_id_fkey" FOREIGN KEY ("enterprise_id") REFERENCES "enterprises"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "technological_cards" ADD CONSTRAINT "technological_cards_variety_id_fkey" FOREIGN KEY ("variety_id") REFERENCES "varieties"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "plantings" ADD CONSTRAINT "plantings_tc_id_fkey" FOREIGN KEY ("tc_id") REFERENCES "technological_cards"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "planting_greenhouse_blocks" ADD CONSTRAINT "planting_greenhouse_blocks_block_id_fkey" FOREIGN KEY ("block_id") REFERENCES "greenhouse_blocks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "planting_greenhouse_blocks" ADD CONSTRAINT "planting_greenhouse_blocks_seeding_id_fkey" FOREIGN KEY ("seeding_id") REFERENCES "plantings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_role_assignments" ADD CONSTRAINT "user_role_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_role_assignments" ADD CONSTRAINT "user_role_assignments_user_role_id_fkey" FOREIGN KEY ("user_role_id") REFERENCES "user_roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enterprise_owners" ADD CONSTRAINT "enterprise_owners_enterprise_id_fkey" FOREIGN KEY ("enterprise_id") REFERENCES "enterprises"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enterprise_owners" ADD CONSTRAINT "enterprise_owners_user_owner_id_fkey" FOREIGN KEY ("user_owner_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enterprise_members" ADD CONSTRAINT "enterprise_members_enterprise_id_fkey" FOREIGN KEY ("enterprise_id") REFERENCES "enterprises"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "enterprise_members" ADD CONSTRAINT "enterprise_members_user_member_id_fkey" FOREIGN KEY ("user_member_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "greenhouse_blocks" ADD CONSTRAINT "greenhouse_blocks_enterprise_id_fkey" FOREIGN KEY ("enterprise_id") REFERENCES "enterprises"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "greenhouse_blocks" ADD CONSTRAINT "greenhouse_blocks_soil_id_fkey" FOREIGN KEY ("soil_id") REFERENCES "soils"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "greenhouses" ADD CONSTRAINT "greenhouses_gh_block_id_fkey" FOREIGN KEY ("gh_block_id") REFERENCES "greenhouse_blocks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "greenhouses" ADD CONSTRAINT "greenhouses_gh_material_id_fkey" FOREIGN KEY ("gh_material_id") REFERENCES "greenhouse_materials"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "greenhouses" ADD CONSTRAINT "greenhouses_gh_shape_type_id_fkey" FOREIGN KEY ("gh_shape_type_id") REFERENCES "greenhouse_shapes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "varieties" ADD CONSTRAINT "varieties_crop_id_fkey" FOREIGN KEY ("crop_id") REFERENCES "crops"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "culture_soil_recommendations" ADD CONSTRAINT "culture_soil_recommendations_crop_id_fkey" FOREIGN KEY ("crop_id") REFERENCES "crops"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "culture_soil_recommendations" ADD CONSTRAINT "culture_soil_recommendations_soil_id_fkey" FOREIGN KEY ("soil_id") REFERENCES "soils"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
