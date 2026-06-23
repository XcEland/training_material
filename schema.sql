-- Sales Pipeline Database
-- 1. 
CREATE DATABASE sales_pipeline;
-- 2. 
CREATE SCHEMA IF NOT EXISTS user_management;
-- 3. 
CREATE SCHEMA IF NOT EXISTS sales_management;
-- 4. 
CREATE SCHEMA IF NOT EXISTS lookups;
-- 5. 
CREATE SCHEMA IF NOT EXISTS product_management;
 
-- ------------------------------------------------- Lookup Tables -----------------------------
 
-- 1. Roles
CREATE TABLE IF NOT EXISTS lookups.roles(
        	id BIGSERIAL PRIMARY KEY,
        	role VARCHAR(60) NOT NULL UNIQUE
);
 
-- 2. Drivers
CREATE TABLE IF NOT EXISTS lookups.drivers(
        	id BIGSERIAL PRIMARY KEY,
        	first_name VARCHAR(50),
        	last_name VARCHAR(50),
        	licenseNumber VARCHAR(50) NOT NULL
);
 
-- 3. Client Statuses
CREATE TABLE IF NOT EXISTS lookups.client_statuses(
        	id BIGSERIAL PRIMARY KEY,
        	status VARCHAR(50) NOT NULL UNIQUE
);
 
-- 4. Deal Statuses
CREATE TABLE IF NOT EXISTS lookups.deal_statuses(
        	id BIGSERIAL PRIMARY KEY,
        	status VARCHAR(100) NOT NULL UNIQUE
);
 
-- 5. Vehicle Types
CREATE TABLE IF NOT EXISTS lookups.vehicle_types (
	id BIGSERIAL PRIMARY KEY,              	
    vehicle_type VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200) NOT NULL
);

-- 6. Rental Services
CREATE TABLE IF NOT EXISTS lookups.rental_services(
    id BIGSERIAL PRIMARY KEY,
    service VARCHAR(100) NOT NULL UNIQUE
);

-- 7. Travel Services
CREATE TABLE IF NOT EXISTS lookups.travel_services(
    id BIGSERIAL PRIMARY KEY,
    service VARCHAR(100) NOT NULL UNIQUE,
    display_order INTEGER NOT NULL UNIQUE
);
 
-- 8. Communication Channels (Client Preferences)
CREATE TABLE IF NOT EXISTS lookups.communication_channels(
    id BIGSERIAL PRIMARY KEY,
    channel VARCHAR(30) NOT NULL UNIQUE,
    display_order INTEGER NOT NULL DEFAULT 100
);

-- 9. Languages (Client Preferences)
CREATE TABLE IF NOT EXISTS lookups.languages(
    id BIGSERIAL PRIMARY KEY,
    language VARCHAR(50) NOT NULL UNIQUE,
    display_order INTEGER NOT NULL DEFAULT 100
);

 -- 10. Branches
CREATE TABLE IF NOT EXISTS lookups.branches(
        	id BIGSERIAL PRIMARY KEY,
        	branch VARCHAR(50) NOT NULL UNIQUE
);

-- ------------------------------------------------- User Management Tables -----------------------------
 
-- 1. Users
CREATE TABLE IF NOT EXISTS user_management.users(
        	user_id BIGSERIAL PRIMARY KEY,
        	first_name VARCHAR(50),
        	last_name VARCHAR(50),
			status VARCHAR(10) NOT NULL,
        	email VARCHAR(50) NOT NULL UNIQUE,
			keycloak_user_id VARCHAR(255),
        	role_id INTEGER NOT NULL,
        	location VARCHAR(100) NOT NULL,
			branch_id BIGINT,
			can_offer_rental_in_travel BOOLEAN NOT NULL DEFAULT FALSE,
        	creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        	update_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 	
        	FOREIGN KEY(role_id) REFERENCES lookups.roles(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
        	FOREIGN KEY(branch_id) REFERENCES lookups.branches(id)
        	ON UPDATE CASCADE
        	ON DELETE NO ACTION
);

-- 11. Exchange Rates
CREATE TABLE IF NOT EXISTS lookups.exchange_rates (
  id             BIGSERIAL PRIMARY KEY,
  from_currency  VARCHAR(3) NOT NULL,
  to_currency    VARCHAR(3) NOT NULL DEFAULT 'USD',
  rate           NUMERIC(20,8) NOT NULL,       
  effective_from TIMESTAMPTZ NOT NULL,         
  created_by     INTEGER NOT NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by     INTEGER,
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(from_currency, to_currency, effective_from),
  FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION,
  FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION
);

CREATE INDEX IF NOT EXISTS idx_fx_pair_effective
  ON lookups.exchange_rates(from_currency, to_currency, effective_from DESC);

-- helper to select "the rate in force" at a moment
CREATE OR REPLACE FUNCTION lookups.fx_rate_at(p_from varchar, p_to varchar, p_at timestamptz)
RETURNS lookups.exchange_rates
LANGUAGE sql STABLE AS $$
  SELECT r.* FROM lookups.exchange_rates r
   WHERE r.from_currency=p_from AND r.to_currency=p_to AND r.effective_from <= p_at
   ORDER BY r.effective_from DESC
   LIMIT 1
$$;

-- ------------------------------------------------- Lookup Values-----------------------------
INSERT INTO lookups.roles(role)
VALUES('Sales Executive'), ('Manager'), ('Administrator'), ('Business Developer');

INSERT INTO lookups.deal_statuses (status)
VALUES ('Deal Initiated'), ('Quotation Generated'), ('Quote Negotiation'), ('Invoice Generated'), ('Deal Closed');

INSERT INTO lookups.client_statuses (status)
VALUES ('New Client'), ('Active'), ('Dormant'), ('Inactive'),('Incomplete Profile'); -- Change 'Quotation' status to 'New Client'
 
INSERT INTO lookups.vehicle_types (vehicle_type, description) VALUES
('Group A (Budget)', 'Budget-friendly vehicle options.'),
('Group B (Mini Van/ City SUV)', 'Compact, economical vehicles for city travel.'),
('Group C (4X4 Trucks)', 'Rugged 4x4 trucks suitable for off-road use.'),
('Group D (SUV)', 'Standard Sport Utility Vehicles.'),
('Group E (Executive)', 'Luxury or high-end executive vehicles.'),
('Group F (Mini Buses)', 'Larger vehicles for group travel.'),
('Group G (Executive SUV)', 'Luxury Sport Utility Vehicles.');

INSERT INTO lookups.rental_services (service) VALUES
('Self Drive Rental'),
('Chauffeur Driven Rental'),
('Airport Transfer'),
('Shuttle Service');

UPDATE lookups.travel_services
SET display_order = display_order + 100
WHERE display_order BETWEEN 1 AND 100;

INSERT INTO lookups.travel_services (service, display_order) VALUES
('Hotel Reservations', 1),
('Air Ticketing', 2),
('Corporate Travel', 3),
('Holiday Packages', 4),
('Accommodation', 5),
('Car Rental', 6),
('Tickets', 7),
('Travel Insurance', 8),
('Travel Packages', 9),
('Visa Assistance', 10)
ON CONFLICT (service) DO UPDATE
SET display_order = EXCLUDED.display_order;

INSERT INTO lookups.communication_channels (channel, display_order) VALUES
('SMS', 1),
('Call', 2),
('Email', 3),
('WhatsApp', 4)
ON CONFLICT (channel) DO NOTHING;

INSERT INTO lookups.languages (language, display_order) VALUES
('English', 1),
('Shona', 2),
('Ndebele', 3)
ON CONFLICT (language) DO NOTHING;

INSERT INTO user_management.users (first_name,last_name,status,email,role_id,location) VALUES (
    'Root',
    'Root',
    'Active',
    'root@impala.co.zw',
    (SELECT id FROM lookups.roles WHERE role = 'Sales Executive'),
    'Harare'
);

INSERT INTO user_management.users (first_name,last_name,status,email,role_id,location) VALUES (
    'Manager',
    'Manager',
    'Active',
    'manager@impala.co.zw',
    (SELECT id FROM lookups.roles WHERE role = 'Manager'),
    'Harare'
);

INSERT INTO lookups.branches(branch) 
VALUES('Harare'),('Bulawayo'),('Victoria Falls');

INSERT INTO lookups.exchange_rates (from_currency, rate, effective_from, created_by)
VALUES ('ZWG', 37.22, NOW(), 1);
 
-- ------------------------------------------------- Product Management Tables -----------------------------
 
-- 1. Products
CREATE TABLE IF NOT EXISTS product_management.products(
        	product_id BIGSERIAL PRIMARY KEY,
        	type VARCHAR(50) NOT NULL UNIQUE,
        	quantity INTEGER NOT NULL CHECK(quantity > 0),
        	created_by INTEGER NOT NULL,
        	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        	updated_by INTEGER,
        	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        	FOREIGN KEY(created_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
        	FOREIGN KEY(updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE     	
);
 
 
-- ------------------------------------------------- Sales Management Tables -----------------------------

-- 1. Clients
CREATE TABLE IF NOT EXISTS sales_management.clients (
	id BIGSERIAL PRIMARY KEY,
	client_type VARCHAR(50) NOT NULL,
	identification_type VARCHAR(50), 
	company_name VARCHAR(70),
	company_reg_number VARCHAR(50) UNIQUE,
	company_reg_date DATE CHECK(company_reg_date < NOW()),               	
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	title VARCHAR(10),
	gender VARCHAR(20),
	dob VARCHAR(20), 
    id_number VARCHAR(50) UNIQUE,        	
	passport_number VARCHAR(50) UNIQUE,
	passport_expiry_date DATE,
	license_number VARCHAR(50), 
	license_acquisition_date DATE CHECK(license_acquisition_date < NOW()),
	is_complete_profile BOOLEAN NOT NULL DEFAULT 'false',
	last_activity_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, --new field
	created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE
);


-- Create a partial unique index for id_number
CREATE UNIQUE INDEX unique_id_number
ON sales_management.clients (id_number)
WHERE id_number IS NOT NULL;
 
CREATE UNIQUE INDEX unique_passport_number
ON sales_management.clients (passport_number)
WHERE passport_number IS NOT NULL;
 
CREATE UNIQUE INDEX unique_company_reg_number
ON sales_management.clients (company_reg_number)
WHERE company_reg_number IS NOT NULL;

-- 1.1 Client Rep Associations
CREATE TABLE IF NOT EXISTS sales_management.client_rep_associations (
    id BIGSERIAL PRIMARY KEY,
    client_id BIGINT NOT NULL,
    sales_rep_user_id BIGINT NOT NULL,
    branch_id BIGINT NOT NULL,

    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE, -- FALSE = Rental, TRUE = Travel

    active BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP NULL,

    created_by BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NULL,
    updated_at TIMESTAMP NULL,

    CHECK (effective_to IS NULL OR effective_to > effective_from),
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (sales_rep_user_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

-- No two active reps from same branch on same client
CREATE UNIQUE INDEX IF NOT EXISTS ux_cra_client_branch_active
ON sales_management.client_rep_associations(client_id, branch_id)
WHERE active = TRUE;

-- No duplicate active assignment rows for same client + rep + service type
CREATE UNIQUE INDEX IF NOT EXISTS ux_cra_client_rep_service_active
ON sales_management.client_rep_associations(client_id, sales_rep_user_id, is_travel_service)
WHERE active = TRUE;

-- 1.2 Deals
CREATE TABLE IF NOT EXISTS sales_management.deals (
	id BIGSERIAL PRIMARY KEY,  	
    client_id INTEGER NOT NULL,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
    deal_category VARCHAR(40),
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
	);

-- deals.deal_category rollout for existing DBs (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'sales_management'
          AND table_name = 'deals'
          AND column_name = 'deal_category'
    ) THEN
        ALTER TABLE sales_management.deals
        ADD COLUMN deal_category VARCHAR(40);
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_deals_deal_category'
          AND conrelid = 'sales_management.deals'::regclass
    ) THEN
        ALTER TABLE sales_management.deals
        ADD CONSTRAINT chk_deals_deal_category
        CHECK (
            deal_category IS NULL
            OR deal_category IN ('New Client', 'Dormant To Active', 'Existing Active Client')
        );
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_deals_deal_category
ON sales_management.deals (deal_category);

CREATE INDEX IF NOT EXISTS idx_deals_deal_category_created_at
ON sales_management.deals (deal_category, created_at DESC);

-- 2. Client Statuses
CREATE TABLE IF NOT EXISTS sales_management.client_statuses(
     status_id INTEGER NOT NULL,
     client_id INTEGER NOT NULL,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     FOREIGN KEY(status_id) REFERENCES lookups.client_statuses(id)
       	ON UPDATE CASCADE
       	ON DELETE CASCADE,
     FOREIGN KEY(client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE     	
);

------1.2 Client latest status (1 row per client)
-- 1) Table
CREATE TABLE IF NOT EXISTS sales_management.client_latest_status (
  client_id   BIGINT PRIMARY KEY,
  status_id   INTEGER NOT NULL,
  status_name VARCHAR(100) NOT NULL,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (status_id) REFERENCES lookups.client_statuses(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 2) Backfill once from history (latest by updated_at)
INSERT INTO sales_management.client_latest_status (client_id, status_id, status_name, updated_at)
SELECT DISTINCT ON (cs.client_id)
       cs.client_id,
       cs.status_id,
       ls.status AS status_name,
       cs.updated_at
FROM sales_management.client_statuses cs
JOIN lookups.client_statuses ls ON ls.id = cs.status_id
ORDER BY cs.client_id, cs.updated_at DESC
ON CONFLICT (client_id) DO UPDATE
SET status_id   = EXCLUDED.status_id,
    status_name = EXCLUDED.status_name,
    updated_at  = EXCLUDED.updated_at;

-- 3) Trigger function to maintain snapshot
CREATE OR REPLACE FUNCTION sales_management.fn_upsert_client_latest_status()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_status_name VARCHAR(100);
BEGIN
  SELECT status INTO v_status_name FROM lookups.client_statuses WHERE id = NEW.status_id;
  INSERT INTO sales_management.client_latest_status (client_id, status_id, status_name, updated_at)
  VALUES (NEW.client_id, NEW.status_id, v_status_name, COALESCE(NEW.updated_at, CURRENT_TIMESTAMP))
  ON CONFLICT (client_id) DO UPDATE
  SET status_id   = EXCLUDED.status_id,
      status_name = EXCLUDED.status_name,
      updated_at  = EXCLUDED.updated_at;
  RETURN NEW;
END $$;
 
-- 2.1 Client Branches
CREATE TABLE IF NOT EXISTS sales_management.company_branches (
	id BIGSERIAL PRIMARY KEY,              	
	client_id INTEGER NOT NULL,
	branch_name VARCHAR(50) NOT NULL,
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE
);
 
-- 3. Notes
CREATE TABLE sales_management.notes(
	id BIGSERIAL PRIMARY KEY,
    client_id INTEGER,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
    subject VARCHAR(200) NOT NULL,
    note VARCHAR(2000) NOT NULL,
    has_attachments BOOLEAN NOT NULL DEFAULT 'false',
	created_by_business_developer BOOLEAN NOT NULL DEFAULT 'false', --new field
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
   	 	ON DELETE CASCADE,
	FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
 
-- 4. Lunch Events
CREATE TABLE sales_management.events(
	id BIGSERIAL PRIMARY KEY,
    subject VARCHAR(200) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    event_outcome  TEXT,
    venue CHARACTER VARYING NOT NULL,
    location VARCHAR(100) NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    reminder VARCHAR(50),
    reminder_date TIMESTAMP,
    status VARCHAR(50) NOT NULL, -- Scheduled, Rescheduled, Completed, Cancelled
    cancellation_reason VARCHAR(100),
    cancellation_date TIMESTAMP,
    rescheduling_reason VARCHAR(100),
    rescheduling_date TIMESTAMP,
    total_amount NUMERIC(15,2) CHECK (total_amount >= 0),
	currency_type VARCHAR(3) NOT NULL DEFAULT 'USD',
    created_by INTEGER NOT NULL,
    client_id INTEGER,
    user_id INTEGER,
    deal_id INTEGER,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
	created_by_business_developer BOOLEAN NOT NULL DEFAULT 'false', --new field
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
   FOREIGN KEY (user_id) REFERENCES user_management.users(user_id)
   	 ON UPDATE CASCADE
    	ON DELETE CASCADE,
   FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
   FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
    	ON UPDATE CASCADE
        ON DELETE CASCADE,
   FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
   FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
   FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

CREATE INDEX IF NOT EXISTS idx_events_notifications_hotpath
ON sales_management.events (created_by, status, reminder, reminder_date);
 
-- 6. Emails
CREATE TABLE sales_management.emails(
	id BIGSERIAL PRIMARY KEY,
    subject VARCHAR(200) NOT NULL,
    content VARCHAR(1000) NOT NULL,
    has_attachments BOOLEAN NOT NULL DEFAULT 'false',
    is_scheduled_email BOOLEAN NOT NULL DEFAULT 'false',
    scheduled_date TIMESTAMP,
    sent_email_date TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    cancellation_reason VARCHAR(100),
    cancellation_date TIMESTAMP,
    rescheduling_reason VARCHAR(100),
    rescheduling_date TIMESTAMP,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
	created_by_business_developer BOOLEAN NOT NULL DEFAULT 'false', --new field
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

-- 7. Email Recipients
CREATE TABLE sales_management.email_recipients(
	id BIGSERIAL PRIMARY KEY,
    email_id INTEGER,
    client_id INTEGER,
    user_id INTEGER,
    deal_id INTEGER,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
	updatedByBusinessDeveloper BOOLEAN NOT NULL DEFAULT 'false', --new field
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (email_id) REFERENCES sales_management.emails(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

 
-- 8. Calls
CREATE TABLE sales_management.calls(
	id BIGSERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    deal_id INTEGER, -- removed not null
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
    type VARCHAR NOT NULL CHECK (type ~* '^(Scheduled|Inbound|Outbound)$'),
    purpose VARCHAR(200) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    scheduled_date TIMESTAMP,
    reminder VARCHAR(50),
    reminder_date TIMESTAMP,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(50) NOT NULL, --Scheduled, Rescheduled, Completed, Cancelled
    cancellation_reason VARCHAR(100),
    cancellation_date TIMESTAMP,
    rescheduling_reason VARCHAR(100),
    rescheduling_date TIMESTAMP,
	created_by_business_developer BOOLEAN NOT NULL DEFAULT 'false', --new field: 
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

CREATE INDEX IF NOT EXISTS idx_calls_status ON sales_management.calls(status);
CREATE INDEX IF NOT EXISTS idx_calls_created_by_status ON sales_management.calls(created_by, status);
CREATE INDEX IF NOT EXISTS idx_calls_scheduled_date ON sales_management.calls(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_calls_client_id ON sales_management.calls(client_id);
CREATE INDEX IF NOT EXISTS idx_calls_deal_id ON sales_management.calls(deal_id);

-- 10. Company Drivers
CREATE TABLE IF NOT EXISTS sales_management.company_drivers (
	id BIGSERIAL PRIMARY KEY,
    branch_id INTEGER,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	title VARCHAR(10),
	gender VARCHAR(20),
	status    VARCHAR(10) NOT NULL DEFAULT 'Active',
	id_number VARCHAR(50) UNIQUE,        	
	passport_number VARCHAR(50) UNIQUE,  	
	license_number VARCHAR(50) UNIQUE,          	
	license_acquisition_date DATE CHECK(license_acquisition_date < NOW()),       	
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES sales_management.company_branches(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
 
CREATE UNIQUE INDEX unique_company_drivers
ON sales_management.company_drivers(id_number)
WHERE id_number IS NOT NULL;
	 
CREATE UNIQUE INDEX unique_license_number
ON sales_management.company_drivers(license_number)
WHERE license_number IS NOT NULL;

-- 11. Contact Person
CREATE TABLE IF NOT EXISTS sales_management.company_contact_person (
	id BIGSERIAL PRIMARY KEY,	
	branch_id INTEGER NOT NULL,
	first_name VARCHAR(50)NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	dob VARCHAR(20), 
	title VARCHAR(10),  	
	department  VARCHAR(100) NOT NULL,      
	is_driver BOOLEAN NOT NULL DEFAULT 'false',
	status    VARCHAR(10) NOT NULL DEFAULT 'Active',
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
   	 	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES sales_management.company_branches(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- 12. Contact Details
CREATE TABLE sales_management.contact_details(
	id BIGSERIAL PRIMARY KEY,
    mobile_number VARCHAR(20) NOT NULL UNIQUE,
    telephone_number VARCHAR(20),
    email  VARCHAR(50) UNIQUE,
    linkedin  VARCHAR(50),
    x VARCHAR(50),
    facebook VARCHAR(50),
    client_id INTEGER,
    company_contact_person_id INTEGER,
    company_driver_id INTEGER,
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (company_contact_person_id) REFERENCES sales_management.company_contact_person(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (company_driver_id) REFERENCES sales_management.company_drivers(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

 
-- 13. Address Details
CREATE TABLE sales_management.address_details(
	id BIGSERIAL PRIMARY KEY,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    country VARCHAR(50),
    client_id INTEGER,
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- 14. Documents
CREATE TABLE sales_management.documents(
	id BIGSERIAL PRIMARY KEY,
    type VARCHAR(30),
    category VARCHAR(100) NOT NULL,
	sub_category VARCHAR(100) NOT NULL,
	new_file_name VARCHAR(100) NOT NULL,
	original_file_name VARCHAR(100) NOT NULL,
    status VARCHAR(10) DEFAULT 'Valid',
    client_id BIGINT,
    company_driver_id BIGINT, 
	company_contact_person_id BIGINT, 
    url VARCHAR(500),
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
  	  ON UPDATE CASCADE
      ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    FOREIGN KEY (company_driver_id) REFERENCES sales_management.company_drivers(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
	FOREIGN KEY (company_contact_person_id) REFERENCES sales_management.company_contact_person(id)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);
 
-- 15. History
CREATE TABLE IF NOT EXISTS sales_management.history (
	id BIGSERIAL PRIMARY KEY,              	
	client_id INTEGER NOT NULL,
	type VARCHAR(80) NOT NULL,
	details JSONB NOT NULL,        	
	created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE
);
-- 17. Deal Statuses
CREATE TABLE IF NOT EXISTS sales_management.deal_statuses(
	id BIGSERIAL PRIMARY KEY,  	
    deal_id INTEGER NOT NULL,
	status VARCHAR(100) NOT NULL,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE
);

-----------------------------------------optimizations-------------------------------------------
------------------------deal insights------------------------------------------------------------
--1.1 Deal latest status (1 row per deal)
-- 1) Table
CREATE TABLE IF NOT EXISTS sales_management.deal_latest_status (
  deal_id     BIGINT PRIMARY KEY,
  status      VARCHAR(100) NOT NULL,
  is_negotiated BOOLEAN NOT NULL DEFAULT FALSE,
  updated_by  BIGINT,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 2) Backfill once from history (latest by updated_at)
INSERT INTO sales_management.deal_latest_status (deal_id, status, updated_by, updated_at)
SELECT DISTINCT ON (ds.deal_id)
       ds.deal_id,
       ds.status,
       ds.updated_by,
       ds.updated_at
FROM sales_management.deal_statuses ds
ORDER BY ds.deal_id, ds.updated_at DESC
ON CONFLICT (deal_id) DO UPDATE
SET status = EXCLUDED.status,
    updated_by = EXCLUDED.updated_by,
    updated_at = EXCLUDED.updated_at;

-- 3) Trigger function: keep snapshot in sync on every insert
CREATE OR REPLACE FUNCTION sales_management.fn_upsert_deal_latest_status()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO sales_management.deal_latest_status (deal_id, status, updated_by, updated_at)
  VALUES (NEW.deal_id, NEW.status, NEW.updated_by, COALESCE(NEW.updated_at, CURRENT_TIMESTAMP))
  ON CONFLICT (deal_id) DO UPDATE
  SET status = EXCLUDED.status,
      updated_by = EXCLUDED.updated_by,
      updated_at = EXCLUDED.updated_at;
  RETURN NEW;
END $$;

---Optional compatibility views make them O(1):
-- Keep the old signature: (deal_id INTEGER, status TEXT, updated_at TIMESTAMP)
CREATE OR REPLACE VIEW sales_management.v_latest_deal_status
AS
SELECT
  dls.deal_id::int          AS deal_id,     -- cast back to int
  dls.status                AS status,
  dls.updated_at            AS updated_at
FROM sales_management.deal_latest_status dls;


-- Keep EXACT old signature: (client_id INTEGER, client_status VARCHAR(50), status_updated_at TIMESTAMP)
CREATE OR REPLACE VIEW sales_management.v_latest_client_status AS
SELECT
  cls.client_id::int           AS client_id,
  cls.status_name::varchar(50) AS client_status,        -- explicit cast to 50
  cls.updated_at               AS status_updated_at
FROM sales_management.client_latest_status cls;

-- 18. Quotations
CREATE TABLE IF NOT EXISTS sales_management.quotations (
	id BIGSERIAL PRIMARY KEY,  
	quotation_id VARCHAR(30) NOT NULL,         	
	client_id INTEGER NOT NULL,
	deal_id INTEGER NOT NULL,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
    service_type INTEGER,
    total_number_of_vehicles INTEGER NOT NULL,
	currency VARCHAR(20) NOT NULL,
    payment_terms VARCHAR(50) NOT NULL,
	total_charge NUMERIC(12,2) NOT NULL, 
	usd_total_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
    hire_charge NUMERIC(12,2) NOT NULL,
	excess_mileage NUMERIC(12,2) NOT NULL DEFAULT 0, -- should be included in calculations for revenue/usd_revenue alongside usd_driver_commission, usd_hire_charge, usd_hire_charge and   for reports
	usd_excess_mileage NUMERIC(12,2) NOT NULL DEFAULT 0,--usd value equivalent
	usd_hire_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	revenue NUMERIC(12,2) NOT NULL DEFAULT 0, --can be usd/zwg/zar/etc value
	usd_revenue NUMERIC(12,2) NOT NULL DEFAULT 0, -- usd value
	tollgate_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	usd_tollgate_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	fuel_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	usd_fuel_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	damages_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	usd_damages_charge NUMERIC(12,2) NOT NULL DEFAULT 0,
	status          VARCHAR(30)   NOT NULL DEFAULT 'Pending',
    vat NUMERIC(12,2) NOT NULL,
    tourism_levy NUMERIC(12,2) NOT NULL,
    refundable_deposit NUMERIC(12,2) NOT NULL,
    driver_commission NUMERIC(12,2) NOT NULL,
	usd_driver_commission NUMERIC(12,2) NOT NULL, --usd value
	start_date_of_hire DATE NOT NULL,
	end_date_of_hire DATE NOT NULL,
    creation_date TIMESTAMP NOT NULL,
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (service_type) REFERENCES lookups.rental_services(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_quotations_status'
          AND conrelid = 'sales_management.quotations'::regclass
    ) THEN
        ALTER TABLE sales_management.quotations
            DROP CONSTRAINT chk_quotations_status;
    END IF;
END
$$;

ALTER TABLE sales_management.quotations
    ADD CONSTRAINT chk_quotations_status
    CHECK (status IN ('Pending', 'Active', 'Invoice', 'Completed'));
 
-- 19. Travel Quotations
CREATE TABLE IF NOT EXISTS sales_management.travel_quotations (
    id BIGSERIAL PRIMARY KEY,
    quotation_id VARCHAR(30) NOT NULL UNIQUE,
    client_id INTEGER NOT NULL,
    deal_id INTEGER NOT NULL,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT TRUE,
    service_type VARCHAR(100) NOT NULL,
    description_of_service TEXT,
    method_of_payment VARCHAR(50),
    currency VARCHAR(20) NOT NULL,
    total_cost NUMERIC(12,2) NOT NULL,
    usd_total_cost NUMERIC(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    creation_date TIMESTAMP NOT NULL,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (deal_id) REFERENCES sales_management.deals(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_travel_quotations_status'
          AND conrelid = 'sales_management.travel_quotations'::regclass
    ) THEN
        ALTER TABLE sales_management.travel_quotations
            DROP CONSTRAINT chk_travel_quotations_status;
    END IF;
END
$$;

ALTER TABLE sales_management.travel_quotations
    ADD CONSTRAINT chk_travel_quotations_status
    CHECK (status IN ('Pending', 'Active', 'Invoice', 'Completed'));

CREATE INDEX IF NOT EXISTS idx_travel_quotations_deal_id
ON sales_management.travel_quotations(deal_id);

CREATE INDEX IF NOT EXISTS idx_travel_quotations_client_id
ON sales_management.travel_quotations(client_id);

CREATE INDEX IF NOT EXISTS idx_travel_quotations_created_by
ON sales_management.travel_quotations(created_by);

CREATE INDEX IF NOT EXISTS idx_travel_quotations_created_at
ON sales_management.travel_quotations(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_travel_quotations_status
ON sales_management.travel_quotations(status);

CREATE INDEX IF NOT EXISTS idx_travel_quotations_served_branch_id
ON sales_management.travel_quotations(served_branch_id);

-- 20. Quotation Details
CREATE TABLE IF NOT EXISTS sales_management.quotation_details (
	id BIGSERIAL PRIMARY KEY,              	
	quotation_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    departure_city VARCHAR(50) NOT NULL,
    destination_city VARCHAR(50) NOT NULL,  
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (quotation_id) REFERENCES sales_management.quotations(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES lookups.vehicle_types(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE
);
 
-- 21. Quotation Negotiations
CREATE TABLE IF NOT EXISTS sales_management.negotiations (
	id BIGSERIAL PRIMARY KEY,  
	quotation_id INTEGER,
	travel_quotation_id BIGINT,
	description TEXT NOT NULL,
	negotiation_reason TEXT NOT NULL, --new field
	prev_details JSONB NOT NULL,
	creation_date TIMESTAMP NOT NULL,    	
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quotation_id) REFERENCES sales_management.quotations(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (travel_quotation_id) REFERENCES sales_management.travel_quotations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    CONSTRAINT chk_negotiations_exactly_one_quotation_ref
        CHECK (num_nonnulls(quotation_id, travel_quotation_id) = 1)
);
 
 
-- 22. Invoices
CREATE TABLE IF NOT EXISTS sales_management.invoices (
	id BIGSERIAL PRIMARY KEY,  	
    quotation_id INTEGER,
    travel_quotation_id BIGINT,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL,
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quotation_id) REFERENCES sales_management.quotations(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
    FOREIGN KEY (travel_quotation_id) REFERENCES sales_management.travel_quotations(id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    CONSTRAINT chk_invoices_exactly_one_quotation_ref
        CHECK (num_nonnulls(quotation_id, travel_quotation_id) = 1)
);
 
-- 23. Forecasts
CREATE TABLE IF NOT EXISTS sales_management.forecasts (
	id BIGSERIAL PRIMARY KEY,  	
    description VARCHAR(1000) NOT NULL,
	forecast_type VARCHAR(50) NOT NULL,
    forecast_interval VARCHAR(100) NOT NULL,
    forecast_timeline VARCHAR(50) NOT NULL,
    month VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE
);

-------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_forecasts_timeline_month_status_created
ON sales_management.forecasts (forecast_timeline, month, status, created_at DESC);

-- Forecasts
CREATE INDEX IF NOT EXISTS idx_forecasts_interval      ON sales_management.forecasts (forecast_interval);
CREATE INDEX IF NOT EXISTS idx_forecasts_timeline      ON sales_management.forecasts (forecast_timeline);
CREATE INDEX IF NOT EXISTS idx_forecasts_status        ON sales_management.forecasts (status);
CREATE INDEX IF NOT EXISTS idx_forecasts_type          ON sales_management.forecasts (forecast_type);
CREATE INDEX IF NOT EXISTS idx_forecasts_created_by    ON sales_management.forecasts (created_by);
CREATE INDEX IF NOT EXISTS idx_forecasts_created_at    ON sales_management.forecasts (created_at);

-- Users & Branches (lookups)
CREATE INDEX IF NOT EXISTS idx_users_user_id           ON user_management.users (user_id);
CREATE INDEX IF NOT EXISTS idx_branches_id             ON lookups.branches (id);

-- 24. Forecast Details
CREATE TABLE IF NOT EXISTS sales_management.forecast_details (
	id BIGSERIAL PRIMARY KEY,  	
    forecast_id INTEGER NOT NULL,
    sales_rep_id INTEGER,
    branch_id INTEGER,
    total_leads INTEGER,
    total_clients INTEGER,
	sales_total INTEGER, -- new field: sales_total is number of closed deals
    total_sales_amount NUMERIC(30,2) NOT NULL,
    total_budget_for_activities NUMERIC(30,2),
    forecast_interval VARCHAR(100) NOT NULL,
    forecast_timeline VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (forecast_id) REFERENCES sales_management.forecasts(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
    FOREIGN KEY (sales_rep_id) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES lookups.branches(id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        	ON UPDATE CASCADE
        	ON DELETE CASCADE
);

-- Details (for subquery filters + joins)
CREATE INDEX IF NOT EXISTS idx_fdetails_forecast_id    ON sales_management.forecast_details (forecast_id);
CREATE INDEX IF NOT EXISTS idx_fdetails_salesrep_id    ON sales_management.forecast_details (sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_fdetails_branch_id      ON sales_management.forecast_details (branch_id);

CREATE INDEX IF NOT EXISTS idx_negotiations_quotation_id
ON sales_management.negotiations (quotation_id);

CREATE INDEX IF NOT EXISTS idx_negotiations_travel_quotation_id
ON sales_management.negotiations (travel_quotation_id);

-- One invoice per quotation reference (rental or travel)
CREATE UNIQUE INDEX IF NOT EXISTS ux_invoices_quotation_id_not_null
ON sales_management.invoices (quotation_id)
WHERE quotation_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_invoices_travel_quotation_id_not_null
ON sales_management.invoices (travel_quotation_id)
WHERE travel_quotation_id IS NOT NULL;

-- Branch filter on users

-- Contact pick path
CREATE INDEX IF NOT EXISTS idx_contact_details_client_pick
ON sales_management.contact_details (client_id, company_driver_id, company_contact_person_id, id);

 
-- 25. Preferences
CREATE TABLE IF NOT EXISTS sales_management.preferences (
	id BIGSERIAL PRIMARY KEY,          	    
	client_id INTEGER NOT NULL,
    preferred_communication_method_for_reminders VARCHAR(30),
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
    	ON UPDATE CASCADE
    	ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
	    ON UPDATE CASCADE
	    ON DELETE CASCADE
);

ALTER TABLE IF EXISTS sales_management.preferences
    ALTER COLUMN preferred_communication_method_for_reminders DROP NOT NULL;

-- Preference model:
--  - preferred_communication_method_for_reminders stays singular on preferences table
--  - communication channels and languages are multi-select via join tables
--  - sales_management.preference_communication_channels
--  - sales_management.preference_languages

-- 25.1 Preference -> Communication Channels (general communication)
CREATE TABLE IF NOT EXISTS sales_management.preference_communication_channels (
    id BIGSERIAL PRIMARY KEY,
    preference_id BIGINT NOT NULL,
    communication_channel_id BIGINT NOT NULL,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (preference_id) REFERENCES sales_management.preferences(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (communication_channel_id) REFERENCES lookups.communication_channels(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    UNIQUE (preference_id, communication_channel_id)
);

CREATE INDEX IF NOT EXISTS idx_pref_comm_channels_pref_id
ON sales_management.preference_communication_channels(preference_id);

CREATE INDEX IF NOT EXISTS idx_pref_comm_channels_channel_id
ON sales_management.preference_communication_channels(communication_channel_id);

-- 25.2 Preference -> Languages
CREATE TABLE IF NOT EXISTS sales_management.preference_languages (
    id BIGSERIAL PRIMARY KEY,
    preference_id BIGINT NOT NULL,
    language_id BIGINT NOT NULL,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (preference_id) REFERENCES sales_management.preferences(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES lookups.languages(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    UNIQUE (preference_id, language_id)
);

CREATE INDEX IF NOT EXISTS idx_pref_languages_pref_id
ON sales_management.preference_languages(preference_id);

CREATE INDEX IF NOT EXISTS idx_pref_languages_language_id
ON sales_management.preference_languages(language_id);
 
-- 26. Giveaways
CREATE TABLE IF NOT EXISTS sales_management.giveaways (
	id BIGSERIAL PRIMARY KEY,  	
    client_id INTEGER NOT NULL,
    type VARCHAR(100) NOT NULL,
    description  VARCHAR(1000),
    purchase_currency VARCHAR(20) NOT NULL,
    purchase_amount NUMERIC(12,2) NOT NULL,
    client_rep_association_id BIGINT,
    attributed_sales_rep_id BIGINT,
    served_branch_id BIGINT,
    is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
	created_by_business_developer BOOLEAN NOT NULL DEFAULT 'false', --new field: 
    created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,
    FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
 
-- 27. Notepad
CREATE TABLE IF NOT EXISTS user_management.notepad (
	id BIGSERIAL PRIMARY KEY,
	note TEXT NOT NULL,
	daily_targets JSONB,
	priority VARCHAR,
	added_to_calendar VARCHAR(10),
	reminder VARCHAR(10),
	reminder_date TIMESTAMP,
	created_by INTEGER NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_by INTEGER,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id) 
	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id) 
	ON UPDATE CASCADE ON DELETE CASCADE 
);


-- 28. Payments
CREATE TABLE IF NOT EXISTS sales_management.payments (
	id           	BIGSERIAL PRIMARY KEY,
	client_id    	BIGINT  	NOT NULL,
	invoice_id   	BIGINT  	NOT NULL,
	client_rep_association_id BIGINT,
	attributed_sales_rep_id BIGINT,
	served_branch_id BIGINT,
	is_travel_service BOOLEAN NOT NULL DEFAULT FALSE,
	received_at  	TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
	currency     	VARCHAR(10) NOT NULL DEFAULT 'USD',
	amount_received  NUMERIC(15,2) NOT NULL CHECK (amount_received > 0),
	usd_amount_received NUMERIC(15,2) NOT NULL DEFAULT 0,
	fx_rate_used        NUMERIC(20,8),
	payment_method   VARCHAR(50) NOT NULL DEFAULT 'bank_transfer',
	reference_number VARCHAR(100),
	notes        	TEXT,
	metadata     	JSONB,
	created_by   	INTEGER 	NOT NULL,
	created_at   	TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_by   	INTEGER,
	updated_at   	TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (client_id)
  	REFERENCES sales_management.clients(id)
  	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (invoice_id)
  	REFERENCES sales_management.invoices(id)
  	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (created_by)
  	REFERENCES user_management.users(user_id)
  	ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (updated_by)
  	REFERENCES user_management.users(user_id)
  	ON UPDATE CASCADE ON DELETE CASCADE,
		FOREIGN KEY (client_rep_association_id) REFERENCES sales_management.client_rep_associations(id)
			ON UPDATE CASCADE
			ON DELETE CASCADE,
	FOREIGN KEY (attributed_sales_rep_id) REFERENCES user_management.users(user_id)
		ON UPDATE CASCADE
		ON DELETE NO ACTION,
	FOREIGN KEY (served_branch_id) REFERENCES lookups.branches(id)
		ON UPDATE CASCADE
		ON DELETE NO ACTION
);
 
CREATE INDEX IF NOT EXISTS idx_payments_client  ON sales_management.payments(client_id);
CREATE INDEX IF NOT EXISTS idx_payments_date	ON sales_management.payments(received_at);
CREATE INDEX IF NOT EXISTS idx_payments_refnum  ON sales_management.payments(reference_number);
CREATE INDEX IF NOT EXISTS idx_payments_attributed_sales_rep_id ON sales_management.payments(attributed_sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_payments_served_branch_id ON sales_management.payments(served_branch_id);
CREATE INDEX IF NOT EXISTS idx_payments_is_travel_service ON sales_management.payments(is_travel_service);

-- Fast top-level filters + sort
CREATE INDEX IF NOT EXISTS idx_payments_received_createdby_id
ON sales_management.payments (received_at DESC, created_by, id DESC);

-- Also keep the per-client index from earlier if you implemented it
CREATE INDEX IF NOT EXISTS idx_payments_client_received_id
ON sales_management.payments (client_id, received_at DESC, id DESC);

-- Join helpers
CREATE INDEX IF NOT EXISTS idx_payments_invoice_id
ON sales_management.payments (invoice_id);
 
-- 29. Invoice Balances
CREATE TABLE IF NOT EXISTS sales_management.invoice_balances (
	invoice_id    	BIGINT PRIMARY KEY,
	client_id     	BIGINT NOT NULL,
	invoice_total 	NUMERIC(15,2) NOT NULL DEFAULT 0,
	amount_paid   	NUMERIC(15,2) NOT NULL DEFAULT 0,
	current_balance   NUMERIC(15,2) GENERATED ALWAYS AS (GREATEST(invoice_total - amount_paid, 0)) STORED,
	usd_invoice_total   NUMERIC(15,2) NOT NULL DEFAULT 0,
	usd_amount_paid   NUMERIC(15,2) NOT NULL DEFAULT 0,
	usd_current_balance NUMERIC(15,2) GENERATED ALWAYS AS (GREATEST(usd_invoice_total - usd_amount_paid, 0)) STORED,
	status        	VARCHAR(20) NOT NULL DEFAULT 'Pending',
	updated_at    	TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (invoice_id) REFERENCES sales_management.invoices(id)
  	  ON UPDATE CASCADE 
	  ON DELETE CASCADE,
	FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
  	  ON UPDATE CASCADE 
	  ON DELETE CASCADE
);

 
CREATE INDEX IF NOT EXISTS idx_invoice_balances_client ON sales_management.invoice_balances(client_id);
CREATE INDEX IF NOT EXISTS idx_invoice_balances_updated_at ON sales_management.invoice_balances(updated_at);
 
-- 30. Payment update Audit
CREATE TABLE IF NOT EXISTS sales_management.payment_update_audit (
  id         	BIGSERIAL PRIMARY KEY,
  payment_id 	BIGINT NOT NULL,
  invoice_id 	BIGINT NOT NULL,
  updated_by 	INTEGER NOT NULL,
  reason   	  TEXT    NOT NULL,
  changed_fields JSONB,
  old_values 	JSONB,
  new_values 	JSONB,
  updated_at 	TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY (payment_id) REFERENCES sales_management.payments(id)
	ON UPDATE CASCADE 
	ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_payment_update_audit_payment ON sales_management.payment_update_audit(payment_id);

 -- 31. Draft Applications
CREATE TABLE sales_management.draft_applications (
    id BIGSERIAL PRIMARY KEY,
    application_type VARCHAR(255),
    applicant_id VARCHAR(255),
    application_details JSONB,
    status VARCHAR(255),
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_drafts_createdby_status_updatedat
ON sales_management.draft_applications (created_by, status, updated_at DESC);

-- If you sometimes fetch without status:
CREATE INDEX IF NOT EXISTS idx_drafts_createdby_updatedat
ON sales_management.draft_applications (created_by, updated_at DESC);

-- 32. Audit Logs
-- CREATE TABLE IF NOT EXISTS sales_management.audits_logs (
-- 	id BIGINT PRIMARY KEY,              	
-- 	client_id INTEGER NOT NULL,
-- 	type VARCHAR(80) NOT NULL,
-- 	comment TEXT NOT NULL,
-- 	changed_values JSONB NOT NULL,        	
-- 	created_by INTEGER NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	updated_by INTEGER,
-- 	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- 	FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
--     	ON UPDATE CASCADE
--     	ON DELETE CASCADE,
--     FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
--     	ON UPDATE CASCADE
--     	ON DELETE CASCADE,
-- 	FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
--     	ON UPDATE CASCADE
--     	ON DELETE CASCADE
-- );

CREATE TABLE IF NOT EXISTS sales_management.audits_logs (
    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    type VARCHAR(80) NOT NULL,
    comment TEXT NOT NULL,
    changed_values JSONB NOT NULL,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES sales_management.clients(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (updated_by) REFERENCES user_management.users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ------------------------------------------------- Views -----------------------------

-- Latest status per deal (1 row per deal; fast to filter pipeline/closed)

-- helpful indexes
CREATE INDEX IF NOT EXISTS idx_deal_statuses_deal_updated ON sales_management.deal_statuses(deal_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_received_at ON sales_management.payments(received_at);
CREATE INDEX IF NOT EXISTS idx_quotations_creation_date ON sales_management.quotations(creation_date);

-- (Optional passthrough view if your code expects it; otherwise skip)
CREATE OR REPLACE VIEW sales_management.v_invoice_balances AS
SELECT invoice_id, client_id,
       invoice_total, amount_paid, current_balance,
       usd_invoice_total, usd_amount_paid, usd_current_balance,
       status, updated_at
FROM   sales_management.invoice_balances;

CREATE OR REPLACE VIEW sales_management.v_client_branch AS
SELECT
    c.id         AS client_id,
    u.location   AS branch_name
FROM sales_management.clients c
JOIN user_management.users u
  ON u.user_id = c.created_by;
;


CREATE INDEX IF NOT EXISTS idx_users_user_id_location
ON user_management.users(user_id, location);


CREATE INDEX IF NOT EXISTS idx_invoice_branch_invoice ON sales_management.invoices(id);
CREATE INDEX IF NOT EXISTS idx_payments_invoice ON sales_management.payments(invoice_id);

-- 3) (Optional) Monthly branch targets (USD).
CREATE TABLE IF NOT EXISTS sales_management.sales_targets (
  id BIGSERIAL PRIMARY KEY,
  branch_name       VARCHAR(100) NOT NULL,
  period_month      DATE NOT NULL,               -- first day of month (e.g., 2025-10-01)
  target_amount_usd NUMERIC(15,2) NOT NULL DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(branch_name, period_month)
);
CREATE INDEX IF NOT EXISTS idx_sales_targets_month ON sales_management.sales_targets(period_month);
CREATE INDEX IF NOT EXISTS idx_sales_targets_branch ON sales_management.sales_targets(branch_name);

-- 3
CREATE OR REPLACE VIEW user_management.v_sales_executives AS
SELECT u.user_id,
       u.first_name,
       u.last_name,
       u.email,
       u.location     AS branch,
       u.role_id
FROM user_management.users u
JOIN lookups.roles r ON r.id = u.role_id
WHERE r.role = 'Sales Executive'
;

-- 3.1 Roles: speed up WHERE r.role = 'Sales Executive'
CREATE INDEX IF NOT EXISTS idx_roles_role
    ON lookups.roles(role);

-- 3.2 Users: speed up join on role_id + filtering / grouping by branch
CREATE INDEX IF NOT EXISTS idx_users_role_branch
    ON user_management.users(role_id, location);

-- 3.3 Users: basic index on role_id alone (for joins)
CREATE INDEX IF NOT EXISTS idx_users_role_id
    ON user_management.users(role_id);

-- 4.1 For joining balances to invoices

-- 4.2 For fast filtering on status (Pending / Partially Paid /Completed)

-- 4.3 Optional: partial index for the hot path (pending only)

-- 4.4 For date-range queries (interval, startDate, endDate)

-- 4.5 For filtering by sales executive + date range

-- 4.6 For invoice status filters, if you ever use i.status

-- 4.7 For grouping / filtering by client_type

-- 4.8 Optional composite index if you often join on id and group by client_type
CREATE INDEX IF NOT EXISTS idx_clients_id_client_type
    ON sales_management.clients(id, client_type);

-- invoice_balances

CREATE INDEX IF NOT EXISTS idx_invoice_balances_status
    ON sales_management.invoice_balances(status);

CREATE INDEX IF NOT EXISTS idx_invoice_balances_pending
    ON sales_management.invoice_balances(invoice_id)
    WHERE status = 'Pending';

-- invoices

CREATE INDEX IF NOT EXISTS idx_invoices_created_by_created_at
    ON sales_management.invoices(created_by, created_at);

CREATE INDEX IF NOT EXISTS idx_invoices_status
    ON sales_management.invoices(status);

-- clients
CREATE INDEX IF NOT EXISTS idx_clients_client_type
    ON sales_management.clients(client_type);

-- 6) Base view for service-usage analytics (quotations -> services -> clients/branch/sales exec)
CREATE OR REPLACE VIEW sales_management.v_service_usage_base AS
SELECT
    q.id              AS quotation_id,
    q.deal_id,
    q.client_id,
    rs.id             AS service_id,
    rs.service        AS service_name_raw,  -- e.g. 'Self Drive Rental'
    -- Normalise to your plural names used in the dashboard:
    CASE
        WHEN rs.service ILIKE 'self drive%'         THEN 'Self Drive Rentals'
        WHEN rs.service ILIKE 'chauffeur driven%'   THEN 'Chauffeur Driven Rentals'
        WHEN rs.service ILIKE 'airport transfer%'   THEN 'Airport Transfers'
        WHEN rs.service ILIKE 'shuttle service%'    THEN 'Shuttle Services'
        ELSE rs.service
    END           AS service_name,

    -- Normalise client type to your plural labels
    CASE
        WHEN c.client_type ILIKE 'individual%' THEN 'Individuals'
        WHEN c.client_type ILIKE 'ngo%'        THEN 'NGOs'
        WHEN c.client_type ILIKE 'corporate%'  THEN 'Corporates'
        WHEN c.client_type ILIKE 'parastatal%' THEN 'Parastatals'
        WHEN c.client_type ILIKE 'embassy%'    THEN 'Embassies'
        WHEN c.client_type ILIKE 'government%' THEN 'Government'
        ELSE c.client_type
    END           AS client_type,

    b.branch_name,
    d.created_by    AS sales_exec_id,
    q.created_at    AS quotation_created_at
FROM sales_management.quotations q
JOIN lookups.rental_services rs
    ON rs.id = q.service_type
JOIN sales_management.clients c
    ON c.id = q.client_id
JOIN sales_management.v_client_branch b
    ON b.client_id = c.id
JOIN sales_management.deals d
    ON d.id = q.deal_id;

-- On quotations (time filter + service link + deal)

CREATE INDEX IF NOT EXISTS idx_quotations_service_type
    ON sales_management.quotations(service_type);


-- On deals (for sales executive filter)


-- Deals: time / sales exec filters


-- Latest status: we already have PK on deal_id via PRIMARY KEY,
-- this helps if you filter/join by status in other reports

-- Quotations: join deals -> quotations

-- Invoices: join quotations -> invoices

-- Invoice balances: join invoices -> balances and aggregate revenue


--8 Base view for vehicle rental patterns
CREATE OR REPLACE VIEW sales_management.v_vehicle_rental_base AS
SELECT
    d.id                 AS deal_id,
    q.id                 AS quotation_id,
    q.created_at         AS quotation_created_at,
    d.created_by         AS sales_executive_id,
    b.branch_name        AS branch_name,
    vt.id                AS vehicle_type_id,
    vt.vehicle_type      AS vehicle_type_name,
    CASE c.client_type
        WHEN 'Individual' THEN 'Individuals'
        ELSE c.client_type
    END                  AS client_type
FROM sales_management.quotations q
JOIN sales_management.deals d
    ON d.id = q.deal_id
JOIN sales_management.clients c
    ON c.id = q.client_id
JOIN sales_management.v_client_branch b
    ON b.client_id = c.id
JOIN sales_management.quotation_details qd
    ON qd.quotation_id = q.id
JOIN lookups.vehicle_types vt
    ON vt.id = qd.vehicle_id;

CREATE INDEX IF NOT EXISTS idx_quotation_details_quotation
    ON sales_management.quotation_details(quotation_id);

CREATE INDEX IF NOT EXISTS idx_quotation_details_vehicle
    ON sales_management.quotation_details(vehicle_id);

--9  Base view for client conversion + revenue analytics
CREATE OR REPLACE VIEW sales_management.v_client_conversion_base AS
WITH client_agg AS (
    SELECT
        c.id          AS client_id,
        c.client_type AS client_type,
        c.created_at  AS client_created_at,
        cb.branch_name,
        d.created_by  AS sales_executive_id,

        -- total revenue from this client (all invoices)
        COALESCE(SUM(ib.usd_amount_paid), 0)::numeric(15,2) AS total_revenue_paid
    FROM sales_management.clients c
    -- branch via creator’s location
    JOIN sales_management.v_client_branch cb
        ON cb.client_id = c.id

    -- who “owns” the deals (for salesExecutiveId filter)
    LEFT JOIN sales_management.deals d
        ON d.client_id = c.id

    -- quote / invoice / payments chain
    LEFT JOIN sales_management.quotations q
        ON q.deal_id = d.id
    LEFT JOIN sales_management.invoices i
        ON i.quotation_id = q.id
    LEFT JOIN sales_management.invoice_balances ib
        ON ib.invoice_id = i.id

    GROUP BY
        c.id,
        c.client_type,
        c.created_at,
        cb.branch_name,
        d.created_by
)
SELECT
    ca.client_id,
    ca.client_type,
    COALESCE(cls.status_name, 'Unknown') AS client_status,  -- 'Active', 'New Client', etc. -- Change 'Quotation' status to 'New Client'
    ca.client_created_at,
    ca.branch_name,
    ca.sales_executive_id,
    ca.total_revenue_paid
FROM client_agg ca
LEFT JOIN sales_management.client_latest_status cls
    ON cls.client_id = ca.client_id;

-- fast join to the snapshot table
CREATE INDEX IF NOT EXISTS idx_client_latest_status_client_id
    ON sales_management.client_latest_status(client_id);

CREATE INDEX IF NOT EXISTS idx_client_latest_status_status_name
    ON sales_management.client_latest_status(status_name);

-- already useful for time-window filters on “new clients”

-- often handy when filtering by sales exec via deals


-- 10 Per-deal performance base for each Sales Executive
CREATE OR REPLACE VIEW sales_management.v_exec_deal_performance_base AS
SELECT
    d.id                 AS deal_id,
    d.created_at         AS deal_created_at,
    d.created_by         AS sales_executive_id,
    u.first_name,
    u.last_name,
    u.email,
    u.location           AS branch,
    dls.status           AS latest_status,
    -- Revenue only from deals that have reached Invoice Generated / Deal Closed
    COALESCE(
        SUM(
            CASE 
                WHEN dls.status IN ('Invoice Generated', 'Deal Closed')
                    THEN ib.usd_amount_paid
                ELSE 0
            END
        ),
        0
    )::numeric(15,2)     AS revenue_paid
FROM sales_management.deals d
JOIN user_management.users u
    ON u.user_id = d.created_by
JOIN lookups.roles r
    ON r.id = u.role_id
   AND r.role = 'Sales Executive'
LEFT JOIN sales_management.deal_latest_status dls
    ON dls.deal_id = d.id
LEFT JOIN sales_management.quotations q
    ON q.deal_id = d.id
LEFT JOIN sales_management.invoices i
    ON i.quotation_id = q.id
LEFT JOIN sales_management.invoice_balances ib
    ON ib.invoice_id = i.id
GROUP BY
    d.id,
    d.created_at,
    d.created_by,
    u.first_name,
    u.last_name,
    u.email,
    u.location,
    dls.status;

-- Deals: created_by + created_at (time filters + exec filters)

-- Latest status: lookup by deal_id + filter by status

-- Quotations: join deals -> quotations

-- Invoices: join quotations -> invoices

-- Invoice balances: join invoices -> balances & aggregate revenue


-- Forecast details: quick lookup for monthly, active, per sales rep
CREATE INDEX IF NOT EXISTS idx_forecast_details_sales_rep_timeline
    ON sales_management.forecast_details(sales_rep_id, forecast_timeline, status);
-- ------------------------------------------------- Performance Indexes -----------------------------
-- Activity paging/sorting
CREATE INDEX IF NOT EXISTS idx_notes_created_at
ON sales_management.notes(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_events_created_at
ON sales_management.events(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_emails_created_at
ON sales_management.emails(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_calls_created_at
ON sales_management.calls(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_giveaways_created_at
ON sales_management.giveaways(created_at DESC);

-- notifications
CREATE INDEX IF NOT EXISTS idx_calls_notify
ON sales_management.calls (created_by, scheduled_date)
WHERE status IN ('Scheduled','Rescheduled')
  AND lower(reminder) = 'yes';

CREATE INDEX IF NOT EXISTS idx_calls_notify_client
ON sales_management.calls (created_by, client_id, scheduled_date)
WHERE status IN ('Scheduled','Rescheduled')
  AND lower(reminder) = 'yes';

CREATE INDEX IF NOT EXISTS idx_events_notify
ON sales_management.events (created_by, start_date)
WHERE status IN ('Scheduled','Rescheduled')
  AND reminder_date IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_events_notify_client
ON sales_management.events (created_by, client_id, start_date)
WHERE status IN ('Scheduled','Rescheduled')
  AND reminder_date IS NOT NULL;
 
-- Join lookups
 
-- Payments query/ordering
CREATE INDEX IF NOT EXISTS idx_payments_invoice_createdat ON sales_management.payments(invoice_id, created_at);
 
-- Deal Closed (prevent dup “closed” rows; currently not added)
CREATE UNIQUE INDEX IF NOT EXISTS ux_deal_statuses_closed_once
ON sales_management.deal_statuses(deal_id)
WHERE status = 'Deal Closed';

-- 11 Primary email per client (so we don’t duplicate rows)
CREATE OR REPLACE VIEW sales_management.v_client_primary_email AS
SELECT DISTINCT ON (cd.client_id)
       cd.client_id,
       cd.email
FROM sales_management.contact_details cd
ORDER BY cd.client_id, cd.id DESC;

-- 12 Client–deal performance base view
CREATE OR REPLACE VIEW sales_management.v_client_deal_performance_base AS
SELECT
    c.id             AS client_id,
    c.client_type,
    -- If company_name present use it, otherwise use "first_name last_name"
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END              AS client_name,
    cpe.email        AS client_email,
    d.id             AS deal_id,
    d.created_at     AS deal_created_at,
    d.created_by     AS sales_executive_id,
    u.first_name     AS sales_exec_first_name,
    u.last_name      AS sales_exec_last_name,
    u.email          AS sales_exec_email,
    u.location       AS branch_name,
    dls.status       AS latest_deal_status,
    COALESCE(
        SUM(
            CASE
                WHEN dls.status IN ('Invoice Generated', 'Deal Closed')
                    THEN ib.usd_amount_paid
                ELSE 0
            END
        ),
        0
    )::numeric(15,2) AS revenue_paid
FROM sales_management.deals d
JOIN sales_management.clients c
    ON c.id = d.client_id
JOIN user_management.users u
    ON u.user_id = d.created_by
LEFT JOIN sales_management.deal_latest_status dls
    ON dls.deal_id = d.id
LEFT JOIN sales_management.quotations q
    ON q.deal_id = d.id
LEFT JOIN sales_management.invoices i
    ON i.quotation_id = q.id
LEFT JOIN sales_management.invoice_balances ib
    ON ib.invoice_id = i.id
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id
GROUP BY
    c.id,
    c.client_type,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END,
    cpe.email,
    d.id,
    d.created_at,
    d.created_by,
    u.first_name,
    u.last_name,
    u.email,
    u.location,
    dls.status;

-- Deals: filter by client & time
CREATE INDEX IF NOT EXISTS idx_deals_client_created_at
    ON sales_management.deals(client_id, created_at);

-- Latest status by deal & status

-- Quotations: deal → quotation

-- Invoices: quotation → invoice

-- Invoice balances: invoice → balance & revenue


-- Contact details: client → email
CREATE INDEX IF NOT EXISTS idx_contact_details_client_id
    ON sales_management.contact_details(client_id);
-- ------------------------------------------------- New Reports Views -----------------------------
-------------------------------- Deal Insights-------------------------------------------

-- 1) Base view: one row per deal with stage, client type, branch and revenue paid
CREATE OR REPLACE VIEW sales_management.v_deal_stage_base AS
SELECT
    d.id                       AS deal_id,
    d.created_at               AS deal_created_at,
    d.created_by               AS sales_exec_id,
    cb.branch_name             AS branch_name,
    vlds.status                AS deal_stage,      -- 'Deal Initiated', 'Quotation Generated', ...
    c.client_type              AS client_type,
    COALESCE(
        SUM(
            CASE
                -- Only count revenue for invoice-related stages
                WHEN vlds.status IN ('Invoice Generated', 'Deal Closed')
                    THEN ib.usd_amount_paid
                ELSE 0
            END
        ),
        0
    )::NUMERIC(15,2)           AS revenue_paid
FROM sales_management.deals d
JOIN sales_management.v_latest_deal_status vlds
    ON vlds.deal_id = d.id
JOIN sales_management.clients c
    ON c.id = d.client_id
JOIN sales_management.v_client_branch cb
    ON cb.client_id = c.id
LEFT JOIN sales_management.quotations q
    ON q.deal_id = d.id
LEFT JOIN sales_management.invoices i
    ON i.quotation_id = q.id
LEFT JOIN sales_management.invoice_balances ib
    ON ib.invoice_id = i.id
GROUP BY
    d.id,
    d.created_at,
    d.created_by,
    cb.branch_name,
    vlds.status,
    c.client_type;

-- Deals: for time and exec filters

CREATE INDEX IF NOT EXISTS idx_deals_created_by_created_at
    ON sales_management.deals(created_by, created_at);

-- Join deals -> quotations

-- Join quotations -> invoices

-- Join invoices -> balances
CREATE INDEX IF NOT EXISTS idx_invoice_balances_invoice
    ON sales_management.invoice_balances(invoice_id);

-- Optional: balances by usd_amount_paid (if you ever filter by it)
CREATE INDEX IF NOT EXISTS idx_invoice_balances_usd_amount_paid
    ON sales_management.invoice_balances(usd_amount_paid);

-- Latest deal status already indexed:
	
CREATE OR REPLACE VIEW sales_management.v_latest_deal_quote_value AS
SELECT DISTINCT ON (q.deal_id)
       q.deal_id,
       q.usd_revenue           AS usd_deal_value, -- Changed from usd_hire_charge
       q.creation_date         AS quote_created_at,
       q.client_id,
       q.id                    AS quotation_pk
FROM sales_management.quotations q
ORDER BY q.deal_id, q.creation_date DESC, q.id DESC;

CREATE INDEX IF NOT EXISTS idx_quotations_dealid_creation
ON sales_management.quotations(deal_id, creation_date DESC, id DESC);

-- helpful index paths already mostly exist:
-- idx_invoices_quotation_id, idx_quotations_deal_id, idx_invoice_balances_invoice
-- Add this if not present:
CREATE INDEX IF NOT EXISTS idx_invoice_deal_branch 
ON sales_management.invoices(id, quotation_id);

CREATE INDEX IF NOT EXISTS idx_invoice_join_perf
ON sales_management.invoices(id, quotation_id);

-------------------------------- Client Analysis Report-------------------------------------------
-- 1.2 client overview snapshot
CREATE OR REPLACE VIEW sales_management.v_client_overview AS
SELECT
    c.id                       AS client_id,
    c.client_type              AS client_type,
    c.created_by               AS sales_exec_id,
    c.created_at               AS client_created_at,
    b.branch_name              AS branch_name,
    lcs.client_status          AS client_status,
    lcs.status_updated_at      AS client_status_updated_at
FROM sales_management.clients c
JOIN sales_management.v_client_branch b
  ON b.client_id = c.id
LEFT JOIN sales_management.v_latest_client_status lcs
  ON lcs.client_id = c.id;

-- client_statuses table: support DISTINCT ON (...) latest status resolution fast
-- Helpful index for performance
CREATE INDEX IF NOT EXISTS idx_client_statuses_client_updated
ON sales_management.client_statuses(client_id, updated_at DESC);

-- clients table: filter by branch (through created_by -> users), by sales exec, and by time window
CREATE INDEX IF NOT EXISTS idx_clients_created_at
ON sales_management.clients(created_at);

CREATE INDEX IF NOT EXISTS idx_clients_created_by
ON sales_management.clients(created_by);

-- users table: support branch filter (branch == users.location)

-- deals table: support deal trend queries and inactive timelines
CREATE INDEX IF NOT EXISTS idx_deals_client_created
ON sales_management.deals(client_id, created_at DESC);



--1.3 Per-client last deal + its latest status :last (most recent) deal per client, + that deal's latest status
CREATE OR REPLACE VIEW sales_management.v_client_last_deal AS
WITH latest_deal AS (
    SELECT DISTINCT ON (d.client_id)
           d.client_id,
           d.id          AS deal_id,
           d.created_at  AS deal_created_at
    FROM sales_management.deals d
    ORDER BY d.client_id, d.created_at DESC, d.id DESC
)
SELECT
    ld.client_id,
    ld.deal_id,
    ld.deal_created_at,
    lds.status       AS last_deal_status,
    lds.updated_at   AS last_deal_status_updated_at
FROM latest_deal ld
LEFT JOIN sales_management.v_latest_deal_status lds
       ON lds.deal_id = ld.deal_id;

-- 1.4:  Client primary contact (so we can surface email fast in API #5)
CREATE OR REPLACE VIEW sales_management.v_client_primary_contact AS
SELECT DISTINCT ON (cd.client_id)
       cd.client_id,
       cd.email,
       cd.mobile_number,
       cd.updated_at AS contact_updated_at
FROM sales_management.contact_details cd
WHERE cd.client_id IS NOT NULL
ORDER BY cd.client_id, cd.updated_at DESC, cd.id DESC;

CREATE INDEX IF NOT EXISTS idx_contact_details_client_updated
ON sales_management.contact_details(client_id, updated_at DESC);

-- ========================= REPORTING NORMALIZATION (RENTAL + TRAVEL) =========================
-- Canonical invoice context for reporting:
-- - supports dual invoice linkage (quotation_id OR travel_quotation_id)
-- - exposes canonical attribution fields
CREATE OR REPLACE VIEW sales_management.v_reporting_invoice_context AS
SELECT
    i.id AS invoice_id,
    i.quotation_id,
    i.travel_quotation_id,
    COALESCE(q.client_id, tq.client_id) AS client_id,
    COALESCE(q.deal_id, tq.deal_id) AS deal_id,
    CASE
        WHEN i.travel_quotation_id IS NOT NULL THEN TRUE
        ELSE COALESCE(i.is_travel_service, FALSE)
    END AS is_travel_service,
    COALESCE(
        i.attributed_sales_rep_id,
        q.attributed_sales_rep_id,
        tq.attributed_sales_rep_id,
        d.attributed_sales_rep_id,
        d.created_by::bigint,
        i.created_by::bigint
    ) AS attributed_sales_rep_id,
    COALESCE(
        i.served_branch_id,
        q.served_branch_id,
        tq.served_branch_id,
        d.served_branch_id,
        cra.branch_id
    ) AS served_branch_id,
    COALESCE(
        i.client_rep_association_id,
        q.client_rep_association_id,
        tq.client_rep_association_id,
        d.client_rep_association_id
    ) AS client_rep_association_id,
    i.created_by,
    i.created_at
FROM sales_management.invoices i
LEFT JOIN sales_management.quotations q
    ON q.id = i.quotation_id
LEFT JOIN sales_management.travel_quotations tq
    ON tq.id = i.travel_quotation_id
LEFT JOIN sales_management.deals d
    ON d.id = COALESCE(q.deal_id, tq.deal_id)
LEFT JOIN sales_management.client_rep_associations cra
    ON cra.id = COALESCE(
        i.client_rep_association_id,
        q.client_rep_association_id,
        tq.client_rep_association_id,
        d.client_rep_association_id
    )
WHERE num_nonnulls(i.quotation_id, i.travel_quotation_id) = 1;

-- invoice -> branch mapping using canonical attribution fields (not client creator)
CREATE OR REPLACE VIEW sales_management.v_invoice_branch AS
SELECT
    ctx.invoice_id AS invoice_id,
    ctx.client_id::integer AS client_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name
FROM sales_management.v_reporting_invoice_context ctx
LEFT JOIN lookups.branches lb
    ON lb.id = ctx.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id::bigint = ctx.attributed_sales_rep_id;

-- outstanding invoice base with service attribution
CREATE OR REPLACE VIEW sales_management.v_outstanding_invoice_base AS
SELECT
    ib.invoice_id,
    ib.usd_current_balance,
    ib.status AS balance_status,
    i.status AS invoice_status,
    i.created_at,
    i.created_by,
    c.client_type,
    ibv.branch_name,
    (CURRENT_DATE::date - i.created_at::date) AS age_days,
    ctx.is_travel_service,
    ctx.attributed_sales_rep_id,
    ctx.served_branch_id
FROM sales_management.invoice_balances ib
JOIN sales_management.invoices i
    ON i.id = ib.invoice_id
JOIN sales_management.v_reporting_invoice_context ctx
    ON ctx.invoice_id = ib.invoice_id
JOIN sales_management.clients c
    ON c.id = ctx.client_id
LEFT JOIN sales_management.v_invoice_branch ibv
    ON ibv.invoice_id = ib.invoice_id;

-- invoice metrics by client type and branch with canonical attribution
CREATE OR REPLACE VIEW sales_management.v_invoice_client_type AS
SELECT
    ib.invoice_id,
    ib.usd_invoice_total,
    ib.usd_current_balance,
    ib.usd_amount_paid,
    ib.status AS balance_status,
    i.status AS invoice_status,
    i.created_at,
    COALESCE(ctx.attributed_sales_rep_id, i.created_by::bigint)::integer AS created_by,
    c.client_type,
    ibv.branch_name,
    ctx.is_travel_service,
    ctx.attributed_sales_rep_id,
    ctx.served_branch_id
FROM sales_management.invoice_balances ib
JOIN sales_management.invoices i
    ON i.id = ib.invoice_id
JOIN sales_management.v_reporting_invoice_context ctx
    ON ctx.invoice_id = ib.invoice_id
JOIN sales_management.clients c
    ON c.id = ctx.client_id
LEFT JOIN sales_management.v_invoice_branch ibv
    ON ibv.invoice_id = ib.invoice_id;

-- deal revenue base with dual invoice linkage + attribution-based branch/exec
CREATE OR REPLACE VIEW sales_management.v_deal_revenue_base AS
WITH deal_invoice_context AS (
    SELECT DISTINCT
        ctx.deal_id,
        ctx.invoice_id,
        ctx.client_id,
        ctx.is_travel_service,
        ctx.attributed_sales_rep_id,
        ctx.served_branch_id
    FROM sales_management.v_reporting_invoice_context ctx
    WHERE ctx.deal_id IS NOT NULL
),
deal_invoice_rollup AS (
    SELECT
        dic.deal_id,
        MAX(dic.client_id) AS client_id,
        BOOL_OR(COALESCE(dic.is_travel_service, FALSE)) AS is_travel_service,
        MAX(dic.attributed_sales_rep_id) FILTER (WHERE dic.attributed_sales_rep_id IS NOT NULL) AS attributed_sales_rep_id,
        MAX(dic.served_branch_id) FILTER (WHERE dic.served_branch_id IS NOT NULL) AS served_branch_id
    FROM deal_invoice_context dic
    GROUP BY dic.deal_id
),
deal_payment_rollup AS (
    SELECT
        dic.deal_id,
        COALESCE(SUM(p.usd_amount_received), 0)::numeric(15,2) AS total_usd_received,
        MAX(p.received_at) AS settlement_received_at
    FROM deal_invoice_context dic
    LEFT JOIN sales_management.payments p
        ON p.invoice_id = dic.invoice_id
    GROUP BY dic.deal_id
),
deal_balance_rollup AS (
    SELECT
        dic.deal_id,
        COALESCE(SUM(ib.usd_current_balance), 0)::numeric(15,2) AS current_outstanding_balance
    FROM deal_invoice_context dic
    JOIN sales_management.invoice_balances ib
        ON ib.invoice_id = dic.invoice_id
    GROUP BY dic.deal_id
)
SELECT
    d.id AS deal_id,
    d.created_at AS deal_created_at,
    COALESCE(d.attributed_sales_rep_id, dir.attributed_sales_rep_id, d.created_by::bigint)::integer AS sales_executive_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    dls.status AS latest_status,
    CASE
        WHEN COALESCE(dbr.current_outstanding_balance, 0) <= 0
            THEN COALESCE(dpr.total_usd_received, 0)::numeric(15,2)
        ELSE 0::numeric(15,2)
    END AS revenue_paid,
    d.client_id,
    COALESCE(d.is_travel_service, dir.is_travel_service, FALSE) AS is_travel_service,
    COALESCE(d.deal_category, 'Existing Active Client')::varchar(40) AS deal_category,
    CASE
        WHEN COALESCE(dbr.current_outstanding_balance, 0) <= 0
             AND COALESCE(dpr.total_usd_received, 0) > 0
            THEN dpr.settlement_received_at
        ELSE NULL::timestamp
    END AS settlement_received_at,
    COALESCE(dbr.current_outstanding_balance, 0)::numeric(15,2) AS current_outstanding_balance
FROM sales_management.deals d
JOIN sales_management.deal_latest_status dls
    ON dls.deal_id = d.id
LEFT JOIN deal_invoice_rollup dir
    ON dir.deal_id = d.id
LEFT JOIN deal_payment_rollup dpr
    ON dpr.deal_id = d.id
LEFT JOIN deal_balance_rollup dbr
    ON dbr.deal_id = d.id
LEFT JOIN lookups.branches lb
    ON lb.id = COALESCE(d.served_branch_id, dir.served_branch_id)
LEFT JOIN user_management.users u
    ON u.user_id::bigint = COALESCE(
        d.attributed_sales_rep_id,
        dir.attributed_sales_rep_id,
        d.created_by::bigint
    );

-- invoice + deal + client + branch + exec flattened from canonical invoice context
CREATE OR REPLACE VIEW sales_management.v_invoice_deal_client_branch AS
SELECT
    i.id AS invoice_id,
    ctx.deal_id::integer AS deal_id,
    ctx.client_id::integer AS client_id,
    c.client_type AS client_type,
    COALESCE(ctx.attributed_sales_rep_id, d.attributed_sales_rep_id, d.created_by::bigint)::integer AS sales_exec_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    vlb.usd_amount_paid AS usd_amount_paid_snapshot,
    vlb.usd_current_balance AS usd_current_balance_snapshot,
    vlb.status AS invoice_status,
    vlb.updated_at AS invoice_snapshot_updated_at,
    ctx.is_travel_service,
    ctx.attributed_sales_rep_id,
    ctx.served_branch_id
FROM sales_management.invoices i
JOIN sales_management.v_reporting_invoice_context ctx
    ON ctx.invoice_id = i.id
LEFT JOIN sales_management.deals d
    ON d.id = ctx.deal_id
JOIN sales_management.clients c
    ON c.id = ctx.client_id
LEFT JOIN lookups.branches lb
    ON lb.id = ctx.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id::bigint = COALESCE(
        ctx.attributed_sales_rep_id,
        d.attributed_sales_rep_id,
        d.created_by::bigint
    )
JOIN sales_management.v_invoice_balances vlb
    ON vlb.invoice_id = i.id;

-- payment-level revenue base grouped later by deals.deal_category
-- this view is intentionally at payment granularity so dashboard filters
-- (date, branch, sales executive, service scope) can be applied in one query
CREATE OR REPLACE VIEW sales_management.v_deal_category_revenue_base AS
SELECT
    p.id AS payment_id,
    p.invoice_id,
    p.received_at,
    COALESCE(p.usd_amount_received, 0)::numeric(15,2) AS usd_amount_received,
    d.id AS deal_id,
    COALESCE(d.deal_category, 'Existing Active Client')::varchar(40) AS deal_category,
    COALESCE(
        p.attributed_sales_rep_id,
        ctx.attributed_sales_rep_id,
        d.attributed_sales_rep_id,
        d.created_by::bigint
    )::integer AS sales_executive_id,
    COALESCE(
        lb.branch::varchar(100),
        u.location::varchar(100)
    ) AS branch_name,
    COALESCE(
        p.is_travel_service,
        ctx.is_travel_service,
        d.is_travel_service,
        FALSE
    ) AS is_travel_service
FROM sales_management.payments p
JOIN sales_management.v_reporting_invoice_context ctx
    ON ctx.invoice_id = p.invoice_id
JOIN sales_management.deals d
    ON d.id = ctx.deal_id
LEFT JOIN lookups.branches lb
    ON lb.id = COALESCE(
        p.served_branch_id,
        ctx.served_branch_id,
        d.served_branch_id
    )
LEFT JOIN user_management.users u
    ON u.user_id::bigint = COALESCE(
        p.attributed_sales_rep_id,
        ctx.attributed_sales_rep_id,
        d.attributed_sales_rep_id,
        d.created_by::bigint
    );

-- ======================================================================================
-- Activities dashboard base views (summary / trends / performance / workload)
-- ======================================================================================

-- One row per activity record (calls, events, emails, notes, giveaways)
CREATE OR REPLACE VIEW sales_management.v_dashboard_activity_records AS
SELECT
    'calls'::varchar(20) AS activity_type,
    c.id::bigint AS activity_id,
    c.created_at AS created_at,
    c.status::varchar(50) AS status,
    COALESCE(c.created_by_business_developer, FALSE) AS created_by_business_developer,
    c.created_by::bigint AS created_by,
    c.client_id::bigint AS client_id,
    c.deal_id::bigint AS deal_id,
    c.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    c.is_travel_service AS is_travel_service,
    COALESCE(c.scheduled_date, c.start_date) AS due_at
FROM sales_management.calls c
LEFT JOIN lookups.branches lb
    ON lb.id = c.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = c.created_by

UNION ALL

SELECT
    'events'::varchar(20) AS activity_type,
    e.id::bigint AS activity_id,
    e.created_at AS created_at,
    e.status::varchar(50) AS status,
    COALESCE(e.created_by_business_developer, FALSE) AS created_by_business_developer,
    e.created_by::bigint AS created_by,
    e.client_id::bigint AS client_id,
    e.deal_id::bigint AS deal_id,
    e.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    e.is_travel_service AS is_travel_service,
    e.start_date AS due_at
FROM sales_management.events e
LEFT JOIN lookups.branches lb
    ON lb.id = e.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = e.created_by

UNION ALL

SELECT
    'emails'::varchar(20) AS activity_type,
    e.id::bigint AS activity_id,
    e.created_at AS created_at,
    e.status::varchar(50) AS status,
    COALESCE(e.created_by_business_developer, FALSE) AS created_by_business_developer,
    e.created_by::bigint AS created_by,
    NULL::bigint AS client_id,
    NULL::bigint AS deal_id,
    e.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    e.is_travel_service AS is_travel_service,
    CASE
        WHEN COALESCE(e.is_scheduled_email, FALSE) = TRUE THEN e.scheduled_date
        ELSE NULL::timestamp
    END AS due_at
FROM sales_management.emails e
LEFT JOIN lookups.branches lb
    ON lb.id = e.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = e.created_by

UNION ALL

SELECT
    'notes'::varchar(20) AS activity_type,
    n.id::bigint AS activity_id,
    n.created_at AS created_at,
    NULL::varchar(50) AS status,
    COALESCE(n.created_by_business_developer, FALSE) AS created_by_business_developer,
    n.created_by::bigint AS created_by,
    n.client_id::bigint AS client_id,
    NULL::bigint AS deal_id,
    n.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    n.is_travel_service AS is_travel_service,
    NULL::timestamp AS due_at
FROM sales_management.notes n
LEFT JOIN lookups.branches lb
    ON lb.id = n.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = n.created_by

UNION ALL

SELECT
    'giveaways'::varchar(20) AS activity_type,
    g.id::bigint AS activity_id,
    g.created_at AS created_at,
    NULL::varchar(50) AS status,
    COALESCE(g.created_by_business_developer, FALSE) AS created_by_business_developer,
    g.created_by::bigint AS created_by,
    g.client_id::bigint AS client_id,
    NULL::bigint AS deal_id,
    g.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    g.is_travel_service AS is_travel_service,
    NULL::timestamp AS due_at
FROM sales_management.giveaways g
LEFT JOIN lookups.branches lb
    ON lb.id = g.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = g.created_by;

-- One row per activity touch point (for unique client/deal coverage)
CREATE OR REPLACE VIEW sales_management.v_dashboard_activity_touches AS
SELECT
    c.created_at AS created_at,
    c.created_by::bigint AS created_by,
    c.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    c.is_travel_service AS is_travel_service,
    c.client_id::bigint AS client_id,
    c.deal_id::bigint AS deal_id
FROM sales_management.calls c
LEFT JOIN lookups.branches lb
    ON lb.id = c.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = c.created_by

UNION ALL

SELECT
    e.created_at AS created_at,
    e.created_by::bigint AS created_by,
    e.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    e.is_travel_service AS is_travel_service,
    e.client_id::bigint AS client_id,
    e.deal_id::bigint AS deal_id
FROM sales_management.events e
LEFT JOIN lookups.branches lb
    ON lb.id = e.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = e.created_by

UNION ALL

SELECT
    n.created_at AS created_at,
    n.created_by::bigint AS created_by,
    n.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    n.is_travel_service AS is_travel_service,
    n.client_id::bigint AS client_id,
    NULL::bigint AS deal_id
FROM sales_management.notes n
LEFT JOIN lookups.branches lb
    ON lb.id = n.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = n.created_by

UNION ALL

SELECT
    g.created_at AS created_at,
    g.created_by::bigint AS created_by,
    g.attributed_sales_rep_id::bigint AS attributed_sales_rep_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    g.is_travel_service AS is_travel_service,
    g.client_id::bigint AS client_id,
    NULL::bigint AS deal_id
FROM sales_management.giveaways g
LEFT JOIN lookups.branches lb
    ON lb.id = g.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = g.created_by

UNION ALL

SELECT
    e.created_at AS created_at,
    e.created_by::bigint AS created_by,
    COALESCE(er.attributed_sales_rep_id, e.attributed_sales_rep_id)::bigint AS attributed_sales_rep_id,
    COALESCE(lb_er.branch::varchar(100), lb_e.branch::varchar(100), u.location::varchar(100)) AS branch_name,
    COALESCE(er.is_travel_service, e.is_travel_service, FALSE) AS is_travel_service,
    er.client_id::bigint AS client_id,
    er.deal_id::bigint AS deal_id
FROM sales_management.email_recipients er
JOIN sales_management.emails e
    ON e.id = er.email_id
LEFT JOIN lookups.branches lb_er
    ON lb_er.id = er.served_branch_id
LEFT JOIN lookups.branches lb_e
    ON lb_e.id = e.served_branch_id
LEFT JOIN user_management.users u
    ON u.user_id = e.created_by;

-- Dashboard filter indexes (activities)
CREATE INDEX IF NOT EXISTS idx_calls_dashboard_filters
ON sales_management.calls (created_at, attributed_sales_rep_id, served_branch_id, is_travel_service);

CREATE INDEX IF NOT EXISTS idx_events_dashboard_filters
ON sales_management.events (created_at, attributed_sales_rep_id, served_branch_id, is_travel_service);

CREATE INDEX IF NOT EXISTS idx_emails_dashboard_filters
ON sales_management.emails (created_at, attributed_sales_rep_id, served_branch_id, is_travel_service);

CREATE INDEX IF NOT EXISTS idx_notes_dashboard_filters
ON sales_management.notes (created_at, attributed_sales_rep_id, served_branch_id, is_travel_service);

CREATE INDEX IF NOT EXISTS idx_giveaways_dashboard_filters
ON sales_management.giveaways (created_at, attributed_sales_rep_id, served_branch_id, is_travel_service);

CREATE INDEX IF NOT EXISTS idx_email_recipients_dashboard_filters
ON sales_management.email_recipients (email_id, client_id, deal_id, attributed_sales_rep_id, served_branch_id, is_travel_service);

-- ========================= PERFORMANCE PASS INDEX PACK (RENTAL + TRAVEL) =========================
-- Deals: service-scope + attribution + branch/date filters used in dashboards/reports
CREATE INDEX IF NOT EXISTS idx_perf_deals_travel_exec_date
    ON sales_management.deals (is_travel_service, created_by, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_deals_travel_attr_date
    ON sales_management.deals (is_travel_service, attributed_sales_rep_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_deals_travel_branch_date
    ON sales_management.deals (is_travel_service, served_branch_id, created_at DESC);

-- Invoices: service-scope + attribution + branch/date and dual-linkage support
CREATE INDEX IF NOT EXISTS idx_perf_invoices_travel_exec_date
    ON sales_management.invoices (is_travel_service, created_by, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_invoices_travel_attr_date
    ON sales_management.invoices (is_travel_service, attributed_sales_rep_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_invoices_travel_branch_date
    ON sales_management.invoices (is_travel_service, served_branch_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_invoices_qid_date
    ON sales_management.invoices (quotation_id, created_at DESC)
    WHERE quotation_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_perf_invoices_tqid_date
    ON sales_management.invoices (travel_quotation_id, created_at DESC)
    WHERE travel_quotation_id IS NOT NULL;

-- Payments: service-scope + attribution + branch/date and owner fallback predicate
CREATE INDEX IF NOT EXISTS idx_perf_payments_travel_date
    ON sales_management.payments (is_travel_service, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_payments_client_travel_date
    ON sales_management.payments (client_id, is_travel_service, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_payments_exec_travel_date
    ON sales_management.payments (attributed_sales_rep_id, is_travel_service, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_payments_branch_travel_date
    ON sales_management.payments (served_branch_id, is_travel_service, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_payments_owner_travel_date
    ON sales_management.payments ((COALESCE(attributed_sales_rep_id, created_by::bigint)), is_travel_service, received_at DESC);

CREATE INDEX IF NOT EXISTS idx_perf_payments_invoice_received
    ON sales_management.payments (invoice_id, received_at DESC);

-- 4) Trigger on the append-only table
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'trg_upsert_deal_latest_status'
          AND tgrelid = 'sales_management.deal_statuses'::regclass
    ) THEN
        DROP TRIGGER trg_upsert_deal_latest_status ON sales_management.deal_statuses;
    END IF;
END
$$;

CREATE TRIGGER trg_upsert_deal_latest_status
AFTER INSERT ON sales_management.deal_statuses
FOR EACH ROW EXECUTE FUNCTION sales_management.fn_upsert_deal_latest_status();

-- 5) Helpful indexes (simple PK already exists)
CREATE INDEX IF NOT EXISTS idx_deal_latest_status_status
  ON sales_management.deal_latest_status(status);

-- 4) Trigger on the append-only table
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'trg_upsert_client_latest_status'
          AND tgrelid = 'sales_management.client_statuses'::regclass
    ) THEN
        DROP TRIGGER trg_upsert_client_latest_status ON sales_management.client_statuses;
    END IF;
END
$$;

CREATE TRIGGER trg_upsert_client_latest_status
AFTER INSERT ON sales_management.client_statuses
FOR EACH ROW EXECUTE FUNCTION sales_management.fn_upsert_client_latest_status();

-- 5) Helpful indexes
CREATE INDEX IF NOT EXISTS idx_client_latest_status_status
  ON sales_management.client_latest_status(status_name);

----------------forecasts---------------------------------


--------------------quotation book -----------------------------------
CREATE OR REPLACE VIEW sales_management.v_quotebook_base AS
SELECT
    q.id                      AS quotation_db_id,
    q.quotation_id            AS quotation_business_id,
    q.client_id               AS client_id,
    q.deal_id                 AS deal_id,
    COALESCE(q.attributed_sales_rep_id::integer, q.created_by) AS sales_person_id,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch_location,

    q.start_date_of_hire      AS start_date_of_hire,
    q.end_date_of_hire        AS end_date_of_hire,
    q.created_at              AS quotation_created_at,
    d.created_at              AS deal_created_at,

    q.status                  AS quotation_status_raw,

    i.id                      AS invoice_id,
    i.status                  AS invoice_status_raw,

    COALESCE(ib.current_balance, ib.usd_current_balance, 0) AS invoice_balance_snapshot,

    CASE
        WHEN i.id IS NOT NULL
             AND COALESCE(ib.current_balance, ib.usd_current_balance, 0) = 0
            THEN 'Completed'

        WHEN i.id IS NOT NULL
             AND COALESCE(ib.current_balance, ib.usd_current_balance, 0) > 0
            THEN 'Invoice'

        WHEN i.id IS NULL
             AND q.status = 'Active'
            THEN 'Active'

        ELSE 'Pending'
    END AS quotebook_status

FROM sales_management.quotations q
JOIN sales_management.deals d
    ON d.id = q.deal_id
JOIN user_management.users u
    ON u.user_id = q.created_by
LEFT JOIN lookups.branches lb
    ON lb.id = q.served_branch_id

LEFT JOIN (
  SELECT DISTINCT ON (quotation_id)
         id, quotation_id, status, created_at
  FROM sales_management.invoices
  ORDER BY quotation_id, created_at DESC NULLS LAST, id DESC
) i ON i.quotation_id = q.id

LEFT JOIN sales_management.invoice_balances ib
    ON ib.invoice_id = i.id;

-- Best index (covering)
CREATE INDEX IF NOT EXISTS idx_invoices_qid_created_at_desc_inc
ON sales_management.invoices (quotation_id, created_at DESC)
INCLUDE (id, status);

-- Ensure balances lookup is fast

-- quotations
CREATE INDEX IF NOT EXISTS idx_quotations_created_by       ON sales_management.quotations(created_by);
CREATE INDEX IF NOT EXISTS idx_quotations_attributed_sales_rep_id ON sales_management.quotations(attributed_sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_quotations_served_branch_id ON sales_management.quotations(served_branch_id);
CREATE INDEX IF NOT EXISTS idx_quotations_hire_dates       ON sales_management.quotations(start_date_of_hire, end_date_of_hire);
CREATE INDEX IF NOT EXISTS idx_quotations_status           ON sales_management.quotations(status);
CREATE INDEX IF NOT EXISTS idx_quotations_business_id      ON sales_management.quotations(quotation_id);

-- invoices / balances
CREATE INDEX IF NOT EXISTS idx_invoices_travel_quotation_id ON sales_management.invoices(travel_quotation_id);
CREATE INDEX IF NOT EXISTS idx_invoice_balances_invoice_id ON sales_management.invoice_balances(invoice_id);

-- users location filter

--------------------audit logs function-----------------------------------

CREATE OR REPLACE FUNCTION sales_management.log_audit_history()
RETURNS trigger AS $$
DECLARE
    change_comment TEXT := COALESCE(current_setting('app.audit_comment', TRUE), 'Record updated');
    change_type    TEXT := COALESCE(current_setting('app.audit_type', TRUE), 'Record updated');

    old_data JSONB := COALESCE(row_to_json(OLD)::JSONB, '{}'::JSONB);
    new_data JSONB := COALESCE(row_to_json(NEW)::JSONB, '{}'::JSONB);
    changed_fields JSONB := '{}'::JSONB;

    key TEXT;
    client_ref BIGINT;
    created_by_val INTEGER;

    branch_ref BIGINT;
    quotation_ref BIGINT;
    travel_quotation_ref BIGINT;
    deal_ref BIGINT;
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NEW;
    END IF;

    -- Prefer updated_by, otherwise created_by (common for audit stamping)
    created_by_val := COALESCE(
        NULLIF(new_data->>'updated_by','')::INTEGER,
        NULLIF(old_data->>'updated_by','')::INTEGER,
        NULLIF(new_data->>'created_by','')::INTEGER,
        NULLIF(old_data->>'created_by','')::INTEGER
    );

    -- Resolve client_ref safely
    IF TG_TABLE_NAME = 'clients' THEN
        client_ref := COALESCE(
            NULLIF(new_data->>'id','')::BIGINT,
            NULLIF(old_data->>'id','')::BIGINT
        );

    ELSIF TG_TABLE_NAME = 'contact_details' THEN
        client_ref := COALESCE(
            NULLIF(new_data->>'client_id','')::BIGINT,
            NULLIF(old_data->>'client_id','')::BIGINT
        );

        IF client_ref IS NULL THEN
            IF COALESCE(NULLIF(new_data->>'company_driver_id','')::BIGINT,
                        NULLIF(old_data->>'company_driver_id','')::BIGINT) IS NOT NULL THEN
                SELECT b.client_id
                  INTO client_ref
                  FROM sales_management.company_drivers d
                  JOIN sales_management.company_branches b ON b.id = d.branch_id
                 WHERE d.id = COALESCE(NULLIF(new_data->>'company_driver_id','')::BIGINT,
                                       NULLIF(old_data->>'company_driver_id','')::BIGINT)
                 LIMIT 1;

            ELSIF COALESCE(NULLIF(new_data->>'company_contact_person_id','')::BIGINT,
                          NULLIF(old_data->>'company_contact_person_id','')::BIGINT) IS NOT NULL THEN
                SELECT b.client_id
                  INTO client_ref
                  FROM sales_management.company_contact_person cp
                  JOIN sales_management.company_branches b ON b.id = cp.branch_id
                 WHERE cp.id = COALESCE(NULLIF(new_data->>'company_contact_person_id','')::BIGINT,
                                        NULLIF(old_data->>'company_contact_person_id','')::BIGINT)
                 LIMIT 1;
            END IF;
        END IF;

    ELSIF TG_TABLE_NAME IN ('company_drivers', 'company_contact_person') THEN
        -- derive via branch_id -> company_branches.client_id
        branch_ref := COALESCE(
            NULLIF(new_data->>'branch_id','')::BIGINT,
            NULLIF(old_data->>'branch_id','')::BIGINT
        );

        IF branch_ref IS NOT NULL THEN
            SELECT b.client_id
              INTO client_ref
              FROM sales_management.company_branches b
             WHERE b.id = branch_ref
             LIMIT 1;
        END IF;

    ELSIF TG_TABLE_NAME IN ('quotation_details', 'negotiations', 'invoices') THEN
        -- derive via quotation_id OR travel_quotation_id -> client_id
        quotation_ref := COALESCE(
            NULLIF(new_data->>'quotation_id','')::BIGINT,
            NULLIF(old_data->>'quotation_id','')::BIGINT
        );

        IF quotation_ref IS NOT NULL THEN
            SELECT q.client_id
              INTO client_ref
              FROM sales_management.quotations q
             WHERE q.id = quotation_ref
             LIMIT 1;
        END IF;

        IF client_ref IS NULL THEN
            travel_quotation_ref := COALESCE(
                NULLIF(new_data->>'travel_quotation_id','')::BIGINT,
                NULLIF(old_data->>'travel_quotation_id','')::BIGINT
            );

            IF travel_quotation_ref IS NOT NULL THEN
                SELECT tq.client_id
                  INTO client_ref
                  FROM sales_management.travel_quotations tq
                 WHERE tq.id = travel_quotation_ref
                 LIMIT 1;
            END IF;
        END IF;

    ELSIF TG_TABLE_NAME IN ('deal_statuses', 'deal_latest_status') THEN
        -- derive via deal_id -> deals.client_id
        deal_ref := COALESCE(
            NULLIF(new_data->>'deal_id','')::BIGINT,
            NULLIF(old_data->>'deal_id','')::BIGINT
        );

        IF deal_ref IS NOT NULL THEN
            SELECT d.client_id
              INTO client_ref
              FROM sales_management.deals d
             WHERE d.id = deal_ref
             LIMIT 1;
        END IF;

    ELSE
        -- Generic: only use explicit client_id if present
        client_ref := COALESCE(
            NULLIF(new_data->>'client_id','')::BIGINT,
            NULLIF(old_data->>'client_id','')::BIGINT
        );
    END IF;

    -- If still not resolvable or not valid, skip audit (avoid breaking business ops)
    IF client_ref IS NULL OR created_by_val IS NULL
       OR NOT EXISTS (SELECT 1 FROM sales_management.clients c WHERE c.id = client_ref) THEN
        RAISE NOTICE 'Skipping audit for %.%: client_ref=% created_by=%',
            TG_TABLE_SCHEMA, TG_TABLE_NAME, client_ref, created_by_val;
        RETURN NEW;
    END IF;

    -- Build changed_fields
    FOR key IN
        SELECT DISTINCT k FROM (
            SELECT jsonb_object_keys(old_data) AS k
            UNION
            SELECT jsonb_object_keys(new_data) AS k
        ) s
        WHERE new_data->k IS DISTINCT FROM old_data->k
          AND NOT (TG_TABLE_NAME = 'clients' AND k = 'last_activity_at')
    LOOP
        changed_fields := changed_fields || jsonb_build_object(
            key,
            jsonb_build_object(
                'old_value', old_data->key,
                'new_value', new_data->key
            )
        );
    END LOOP;

    IF changed_fields = '{}'::JSONB THEN
        RETURN NEW;
    END IF;

    INSERT INTO sales_management.audits_logs (
        client_id,
        type,
        comment,
        changed_values,
        created_by
    ) VALUES (
        client_ref,
        change_type,
        change_comment,
        changed_fields,
        created_by_val
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--------------------audit logs Triggers-----------------------------

DO $$
DECLARE
    t TEXT;
    trg TEXT;
    rel OID;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'address_details',
        'contact_details',
        'client_latest_status',
        'client_statuses',
        'clients',
        'company_branches',
        'company_contact_person',
        'company_drivers',
        'deal_latest_status',
        'deal_statuses',
        'deals',
        'forecast_details',
        'forecasts',
        'giveaways',
        'history',
        'invoice_balances',
        'invoices',
        'negotiations',
        'payments',
        'preferences',
        'quotation_details',
        'quotations',
        'sales_targets',
		'documents'
    ]
    LOOP
        trg := format('trg_%s_audit', t);
        rel := to_regclass('sales_management.' || t);

        IF rel IS NULL THEN
            RAISE NOTICE 'Skipping trigger for %.% (table not found)', 'sales_management', t;
            CONTINUE;
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM pg_trigger
            WHERE tgname = trg
              AND tgrelid = rel
        ) THEN
            EXECUTE format(
                'CREATE TRIGGER %I AFTER UPDATE ON sales_management.%I FOR EACH ROW EXECUTE FUNCTION sales_management.log_audit_history()',
                trg, t
            );
        END IF;
    END LOOP;
END
$$;

-- --------------------------- drill down tables --------------------------------------------------------------------------
-- ---------------------------------------------1. revenue generated---------------------------------------------
CREATE OR REPLACE VIEW sales_management.v_revenue_gained_drilldown_base AS
SELECT
    c.id AS client_id,
    c.client_type,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END AS client_name,
    cpe.email AS client_email,

    u.user_id AS sales_executive_id,
    u.first_name AS sales_exec_first_name,
    u.last_name  AS sales_exec_last_name,
    u.email      AS sales_exec_email,
    b.branch_name AS branch,

    b.deal_id,
    b.deal_created_at,
    b.latest_status AS latest_deal_status,
    b.settlement_received_at,
    b.revenue_paid,
    b.is_travel_service
FROM sales_management.v_deal_revenue_base b
JOIN sales_management.clients c
    ON c.id = b.client_id
JOIN user_management.users u
    ON u.user_id = b.sales_executive_id
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id;

-- Deals: filter by created_at + created_by and join to status/client
CREATE INDEX IF NOT EXISTS idx_deals_created_at        ON sales_management.deals (created_at);
CREATE INDEX IF NOT EXISTS idx_deals_created_by_date   ON sales_management.deals (created_by, created_at);
CREATE INDEX IF NOT EXISTS idx_deals_client_id         ON sales_management.deals (client_id);

-- Latest status: join by deal_id and filter by status in aggregates
CREATE INDEX IF NOT EXISTS idx_deal_latest_status_deal ON sales_management.deal_latest_status (deal_id);
CREATE INDEX IF NOT EXISTS idx_deal_latest_status_stat ON sales_management.deal_latest_status (status);

-- Invoices: filter by created_at and join to quotation
CREATE INDEX IF NOT EXISTS idx_invoices_quotation_id   ON sales_management.invoices (quotation_id);

-- Quotations: join invoice->quotation and quotation->deal/client

-- Users: branch filter and join by user_id

-- Contact details: supports v_client_primary_email (ORDER BY client_id, id DESC)
CREATE INDEX IF NOT EXISTS idx_contact_details_client_id_id
  ON sales_management.contact_details (client_id, id DESC);

-- ---------------------------------------------2. Outstanding Balances---------------------------------------------
CREATE OR REPLACE VIEW sales_management.v_outstanding_balances_drilldown_base AS
SELECT
    c.id AS client_id,
    c.client_type,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END AS client_name,
    cpe.email AS client_email,

    u.user_id AS sales_executive_id,
    u.first_name AS sales_exec_first_name,
    u.last_name  AS sales_exec_last_name,
    u.email      AS sales_exec_email,
    COALESCE(lb.branch::varchar(100), u.location::varchar(100)) AS branch,

    i.id AS invoice_id,
    i.created_at AS invoice_created_at,

    ib.status AS balance_status,
    ib.usd_invoice_total AS usd_invoice_total,
    ib.usd_current_balance AS usd_current_balance,
    ctx.is_travel_service
FROM sales_management.invoices i
JOIN sales_management.invoice_balances ib
    ON ib.invoice_id = i.id
JOIN sales_management.v_reporting_invoice_context ctx
    ON ctx.invoice_id = i.id
LEFT JOIN sales_management.deals d
    ON d.id = ctx.deal_id
JOIN user_management.users u
    ON u.user_id::bigint = COALESCE(
        ctx.attributed_sales_rep_id,
        d.attributed_sales_rep_id,
        d.created_by::bigint
    )
JOIN sales_management.clients c
    ON c.id = ctx.client_id
LEFT JOIN lookups.branches lb
    ON lb.id = ctx.served_branch_id
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id;


-- invoices time filtering

-- invoice_balances pending lookup (PK invoice_id already exists, but status + balance helps)
CREATE INDEX IF NOT EXISTS idx_invoice_balances_status_balance
  ON sales_management.invoice_balances (status, usd_current_balance);

-- quotations joins
CREATE INDEX IF NOT EXISTS idx_quotations_client_id ON sales_management.quotations (client_id);

-- deals join to created_by + client_id (and date if needed later)

-- users branch filtering
CREATE INDEX IF NOT EXISTS idx_users_location_user ON user_management.users (location, user_id);

-- -----------------------------------------------------------------3. revenue by client category-----------------------------------------
CREATE OR REPLACE VIEW sales_management.v_revenue_by_client_category_drilldown_base AS
SELECT
    c.id AS client_id,
    c.client_type,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END AS client_name,
    cpe.email AS client_email,

    u.user_id AS sales_executive_id,
    u.first_name AS sales_exec_first_name,
    u.last_name  AS sales_exec_last_name,
    u.email      AS sales_exec_email,
    b.branch_name AS branch,

    b.deal_id,
    b.settlement_received_at,
    COALESCE(b.revenue_paid, 0)::numeric(15,2) AS usd_amount_paid,
    COALESCE(b.current_outstanding_balance, 0)::numeric(15,2) AS usd_current_balance,
    b.is_travel_service
FROM sales_management.v_deal_revenue_base b
JOIN sales_management.clients c
    ON c.id = b.client_id
JOIN user_management.users u
    ON u.user_id = b.sales_executive_id
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id;

CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON sales_management.invoices(created_at);
-- users.user_id is PK; optional but location filter benefits from:



-- ---------------------------------------------------- 4. Drilldown base for rental service usage (no revenue)
DO $$
BEGIN
    IF to_regclass('sales_management.v_rental_service_usage_drilldown_base') IS NOT NULL THEN
        DROP VIEW sales_management.v_rental_service_usage_drilldown_base;
    END IF;
END
$$;

CREATE VIEW sales_management.v_rental_service_usage_drilldown_base AS
SELECT
    -- service category: rental rows created from travel associations roll up into Travel > Car Rental
    CASE
        WHEN COALESCE(cra.is_travel_service, FALSE) THEN 'Travel'
        ELSE 'Car Rental'
    END AS service_scope,

    CASE
        WHEN COALESCE(cra.is_travel_service, FALSE) THEN 1
        ELSE 2
    END AS service_scope_sort,

    -- normalize service name to dashboard labels
    CASE
        WHEN COALESCE(cra.is_travel_service, FALSE) THEN COALESCE(ts_car.service, 'Car Rental')
        WHEN rs.service ILIKE 'self drive%'         THEN 'Self Drive Rentals'
        WHEN rs.service ILIKE 'chauffeur driven%'   THEN 'Chauffeur Driven Rentals'
        WHEN rs.service ILIKE 'airport transfer%'   THEN 'Airport Transfers'
        WHEN rs.service ILIKE 'shuttle service%'    THEN 'Shuttle Services'
        ELSE rs.service
    END AS service,

    -- stable ordering for groups
    CASE
        WHEN COALESCE(cra.is_travel_service, FALSE) THEN COALESCE(ts_car.display_order, 9999)
        WHEN rs.service ILIKE 'self drive%'         THEN 1
        WHEN rs.service ILIKE 'chauffeur driven%'   THEN 2
        WHEN rs.service ILIKE 'airport transfer%'   THEN 3
        WHEN rs.service ILIKE 'shuttle service%'    THEN 4
        ELSE 99
    END AS service_sort,

    -- client
    c.id AS client_id,
    c.client_type AS client_type_raw,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END AS client_name,
    cpe.email AS client_email,

    -- sales executive (deal owner)
    u.user_id AS sales_executive_id,
    u.first_name AS sales_exec_first_name,
    u.last_name  AS sales_exec_last_name,
    u.email      AS sales_exec_email,
    u.location   AS branch,

    -- deal / time
    d.id         AS deal_id,
    q.created_at AS quotation_created_at

FROM sales_management.quotations q
JOIN lookups.rental_services rs
    ON rs.id = q.service_type
JOIN sales_management.deals d
    ON d.id = q.deal_id
JOIN user_management.users u
    ON u.user_id = d.created_by
JOIN sales_management.clients c
    ON c.id = q.client_id
LEFT JOIN sales_management.client_rep_associations cra
    ON cra.id = COALESCE(q.client_rep_association_id, d.client_rep_association_id)
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id
LEFT JOIN lookups.travel_services ts_car
    ON LOWER(BTRIM(ts_car.service)) = 'car rental'

UNION ALL

SELECT
    'Travel' AS service_scope,
    1 AS service_scope_sort,

    -- rental sub-services logged on travel quotations roll up to Travel > Car Rental
    CASE
        WHEN BTRIM(COALESCE(tq.service_type, '')) ILIKE 'self drive%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'chauffeur driven%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'airport transfer%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'shuttle service%'
        THEN COALESCE(ts_car_travel.service, 'Car Rental')
        ELSE COALESCE(ts.service, BTRIM(tq.service_type))
    END AS service,

    -- stable ordering for groups (travel)
    CASE
        WHEN BTRIM(COALESCE(tq.service_type, '')) ILIKE 'self drive%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'chauffeur driven%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'airport transfer%'
          OR BTRIM(COALESCE(tq.service_type, '')) ILIKE 'shuttle service%'
        THEN COALESCE(ts_car_travel.display_order, 9999)
        ELSE COALESCE(ts.display_order, 9999)
    END AS service_sort,

    -- client
    c.id AS client_id,
    c.client_type AS client_type_raw,
    CASE
        WHEN COALESCE(c.company_name, '') <> '' THEN c.company_name
        ELSE TRIM(BOTH ' ' FROM COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, ''))
    END AS client_name,
    cpe.email AS client_email,

    -- sales executive (deal owner)
    u.user_id AS sales_executive_id,
    u.first_name AS sales_exec_first_name,
    u.last_name  AS sales_exec_last_name,
    u.email      AS sales_exec_email,
    u.location   AS branch,

    -- deal / time
    d.id         AS deal_id,
    COALESCE(tq.created_at, tq.creation_date) AS quotation_created_at

FROM sales_management.travel_quotations tq
JOIN sales_management.deals d
    ON d.id = tq.deal_id
JOIN user_management.users u
    ON u.user_id = d.created_by
JOIN sales_management.clients c
    ON c.id = tq.client_id
LEFT JOIN sales_management.v_client_primary_email cpe
    ON cpe.client_id = c.id
LEFT JOIN lookups.travel_services ts
    ON LOWER(BTRIM(ts.service)) = LOWER(BTRIM(tq.service_type))
LEFT JOIN lookups.travel_services ts_car_travel
    ON LOWER(BTRIM(ts_car_travel.service)) = 'car rental';

-- filter by time quickly
CREATE INDEX IF NOT EXISTS idx_quotations_created_at
  ON sales_management.quotations(created_at);

-- join + optional filtering patterns
CREATE INDEX IF NOT EXISTS idx_quotations_service_type_created_at
  ON sales_management.quotations(service_type, created_at);

CREATE INDEX IF NOT EXISTS idx_quotations_deal_id
  ON sales_management.quotations(deal_id);

CREATE INDEX IF NOT EXISTS idx_deals_created_by
  ON sales_management.deals(created_by);

-- branch filter on users.location
CREATE INDEX IF NOT EXISTS idx_users_location
  ON user_management.users(location);

-- Name-search performance for /api/v1/sales/clients/core/search (individual clients)
-- Supports LOWER(..) LIKE '%value%' on first_name / last_name / full name.
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

CREATE INDEX IF NOT EXISTS idx_clients_individual_first_name_trgm
  ON sales_management.clients
  USING gin (lower(first_name) public.gin_trgm_ops)
  WHERE lower(client_type) = 'individual';

CREATE INDEX IF NOT EXISTS idx_clients_individual_last_name_trgm
  ON sales_management.clients
  USING gin (lower(last_name) public.gin_trgm_ops)
  WHERE lower(client_type) = 'individual';

CREATE INDEX IF NOT EXISTS idx_clients_individual_full_name_trgm
  ON sales_management.clients
  USING gin (lower(btrim(coalesce(first_name, '') || ' ' || coalesce(last_name, ''))) public.gin_trgm_ops)
  WHERE lower(client_type) = 'individual';

-- ------------------------------------------------- for dormant/inactive client flags -----------------------------------------------------------------
/* ============================================================
   CLIENT ACTIVITY HEARTBEAT 
   Purpose:
   - Keep sales_management.clients.last_activity_at updated whenever
     a client has "activity" (insert OR update events across key tables).
   - This is the canonical timestamp used later by the inactivity scheduler
     (Active / Inactive / Dormant).
   ============================================================ */

-- 0. Ensure the heartbeat column exists + index
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'sales_management'
          AND table_name = 'clients'
          AND column_name = 'last_activity_at'
    ) THEN
        ALTER TABLE sales_management.clients
        ADD COLUMN last_activity_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_clients_last_activity_at
ON sales_management.clients(last_activity_at);

-- 1. Central touch function (single source of truth for updating last_activity_at)
CREATE OR REPLACE FUNCTION sales_management.touch_client_activity(p_client_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE sales_management.clients
  SET last_activity_at = CURRENT_TIMESTAMP
  WHERE id = p_client_id;
END;
$$;

-- ============================================================
-- 2. Triggers for each activity table (INSERT + UPDATE)
-- ============================================================

DO $$
DECLARE
    trigger_to_drop RECORD;
BEGIN
    FOR trigger_to_drop IN
        SELECT *
        FROM (VALUES
            ('trg_touch_client_calls_ins', 'sales_management.calls'),
            ('trg_touch_client_calls_upd', 'sales_management.calls'),
            ('trg_touch_client_events_ins', 'sales_management.events'),
            ('trg_touch_client_events_upd', 'sales_management.events'),
            ('trg_touch_client_giveaways_ins', 'sales_management.giveaways'),
            ('trg_touch_client_giveaways_upd', 'sales_management.giveaways'),
            ('trg_touch_client_email_recipients_ins', 'sales_management.email_recipients'),
            ('trg_touch_client_email_recipients_upd', 'sales_management.email_recipients'),
            ('trg_touch_client_quotations_ins', 'sales_management.quotations'),
            ('trg_touch_client_quotations_upd', 'sales_management.quotations'),
            ('trg_touch_client_negotiations_ins', 'sales_management.negotiations'),
            ('trg_touch_client_negotiations_upd', 'sales_management.negotiations'),
            ('trg_touch_client_invoices_ins', 'sales_management.invoices'),
            ('trg_touch_client_invoices_upd', 'sales_management.invoices'),
            ('trg_touch_client_payments_ins', 'sales_management.payments'),
            ('trg_touch_client_payments_upd', 'sales_management.payments'),
            ('trg_touch_client_deals_ins', 'sales_management.deals'),
            ('trg_touch_client_deals_upd', 'sales_management.deals'),
            ('trg_touch_client_travel_quotations_ins', 'sales_management.travel_quotations'),
            ('trg_touch_client_travel_quotations_upd', 'sales_management.travel_quotations'),
            ('trg_touch_client_deal_statuses_ins', 'sales_management.deal_statuses'),
            ('trg_touch_client_deal_statuses_upd', 'sales_management.deal_statuses'),
            ('trg_touch_client_deal_latest_status_ins', 'sales_management.deal_latest_status'),
            ('trg_touch_client_deal_latest_status_upd', 'sales_management.deal_latest_status')
        ) AS triggers(trigger_name, relation_name)
    LOOP
        IF EXISTS (
            SELECT 1
            FROM pg_trigger
            WHERE tgname = trigger_to_drop.trigger_name
              AND tgrelid = trigger_to_drop.relation_name::regclass
        ) THEN
            EXECUTE format(
                'DROP TRIGGER %I ON %s',
                trigger_to_drop.trigger_name,
                trigger_to_drop.relation_name
            );
        END IF;
    END LOOP;
END
$$;

-- 2.1 Calls (touch on insert and on updates, since calls can be created then completed later)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_calls()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_calls_ins
AFTER INSERT ON sales_management.calls
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_calls();

CREATE TRIGGER trg_touch_client_calls_upd
AFTER UPDATE ON sales_management.calls
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_calls();


-- 2.2 Events (touch on insert and on updates; client_id may be null)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_events()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_events_ins
AFTER INSERT ON sales_management.events
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_events();

CREATE TRIGGER trg_touch_client_events_upd
AFTER UPDATE ON sales_management.events
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_events();


-- 2.3 Giveaways (touch on insert and on updates)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_giveaways()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_giveaways_ins
AFTER INSERT ON sales_management.giveaways
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_giveaways();

CREATE TRIGGER trg_touch_client_giveaways_upd
AFTER UPDATE ON sales_management.giveaways
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_giveaways();


-- 2.4 Email recipients (touch on insert and on updates; this is the link table to clients)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_email_recipients()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_email_recipients_ins
AFTER INSERT ON sales_management.email_recipients
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_email_recipients();

CREATE TRIGGER trg_touch_client_email_recipients_upd
AFTER UPDATE ON sales_management.email_recipients
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_email_recipients();


-- 2.5 Quotations (touch on insert and on updates; quotations are client engagement)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_quotations()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_quotations_ins
AFTER INSERT ON sales_management.quotations
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_quotations();

CREATE TRIGGER trg_touch_client_quotations_upd
AFTER UPDATE ON sales_management.quotations
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_quotations();


-- 2.6 Negotiations (touch on insert and on updates; derive client via quotation_id or travel_quotation_id)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_negotiations()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_client_id BIGINT;
BEGIN
  IF NEW.quotation_id IS NOT NULL THEN
    SELECT q.client_id INTO v_client_id
    FROM sales_management.quotations q
    WHERE q.id = NEW.quotation_id;
  ELSIF NEW.travel_quotation_id IS NOT NULL THEN
    SELECT tq.client_id INTO v_client_id
    FROM sales_management.travel_quotations tq
    WHERE tq.id = NEW.travel_quotation_id;
  END IF;

  IF v_client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(v_client_id);
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_negotiations_ins
AFTER INSERT ON sales_management.negotiations
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_negotiations();

CREATE TRIGGER trg_touch_client_negotiations_upd
AFTER UPDATE ON sales_management.negotiations
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_negotiations();


-- 2.7 Invoices (touch on insert and on updates; derive client via quotation_id or travel_quotation_id)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_invoices()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_client_id BIGINT;
BEGIN
  IF NEW.quotation_id IS NOT NULL THEN
    SELECT q.client_id INTO v_client_id
    FROM sales_management.quotations q
    WHERE q.id = NEW.quotation_id;
  ELSIF NEW.travel_quotation_id IS NOT NULL THEN
    SELECT tq.client_id INTO v_client_id
    FROM sales_management.travel_quotations tq
    WHERE tq.id = NEW.travel_quotation_id;
  END IF;

  IF v_client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(v_client_id);
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_invoices_ins
AFTER INSERT ON sales_management.invoices
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_invoices();

CREATE TRIGGER trg_touch_client_invoices_upd
AFTER UPDATE ON sales_management.invoices
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_invoices();


-- 2.8 Payments (touch on insert and on updates; payments are strong engagement signals)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_payments()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_payments_ins
AFTER INSERT ON sales_management.payments
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_payments();

CREATE TRIGGER trg_touch_client_payments_upd
AFTER UPDATE ON sales_management.payments
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_payments();


-- 2.9 Deals (touch on insert and on updates; deals are central engagement objects)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_deals()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_deals_ins
AFTER INSERT ON sales_management.deals
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_deals();

CREATE TRIGGER trg_touch_client_deals_upd
AFTER UPDATE ON sales_management.deals
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_deals();

-- 2.10 Travel quotations (touch on insert and on updates)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_travel_quotations()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(NEW.client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_travel_quotations_ins
AFTER INSERT ON sales_management.travel_quotations
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_travel_quotations();

CREATE TRIGGER trg_touch_client_travel_quotations_upd
AFTER UPDATE ON sales_management.travel_quotations
FOR EACH ROW
WHEN (NEW.client_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_travel_quotations();

-- 2.11 Deal statuses (touch client via deal_id on insert and update)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_deal_statuses()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_client_id BIGINT;
BEGIN
  IF NEW.deal_id IS NOT NULL THEN
    SELECT d.client_id INTO v_client_id
    FROM sales_management.deals d
    WHERE d.id = NEW.deal_id;
  END IF;

  IF v_client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(v_client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_deal_statuses_ins
AFTER INSERT ON sales_management.deal_statuses
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_deal_statuses();

CREATE TRIGGER trg_touch_client_deal_statuses_upd
AFTER UPDATE ON sales_management.deal_statuses
FOR EACH ROW
WHEN (NEW.deal_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_deal_statuses();

-- 2.12 Deal latest status cache (touch client via deal_id on insert and update)
CREATE OR REPLACE FUNCTION sales_management.trg_touch_client_from_deal_latest_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_client_id BIGINT;
BEGIN
  IF NEW.deal_id IS NOT NULL THEN
    SELECT d.client_id INTO v_client_id
    FROM sales_management.deals d
    WHERE d.id = NEW.deal_id;
  END IF;

  IF v_client_id IS NOT NULL THEN
    PERFORM sales_management.touch_client_activity(v_client_id);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_touch_client_deal_latest_status_ins
AFTER INSERT ON sales_management.deal_latest_status
FOR EACH ROW
EXECUTE FUNCTION sales_management.trg_touch_client_from_deal_latest_status();

CREATE TRIGGER trg_touch_client_deal_latest_status_upd
AFTER UPDATE ON sales_management.deal_latest_status
FOR EACH ROW
WHEN (NEW.deal_id IS NOT NULL)
EXECUTE FUNCTION sales_management.trg_touch_client_from_deal_latest_status();

-- 3. One-time backfill: existing clients should not all look "active today"
UPDATE sales_management.clients
SET last_activity_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)
WHERE last_activity_at IS NULL
   OR last_activity_at = CURRENT_TIMESTAMP;
