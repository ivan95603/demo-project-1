--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.5

-- Started on 2025-08-01 02:17:12 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS demodb;
--
-- TOC entry 3380 (class 1262 OID 24577)
-- Name: demodb; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE demodb WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE demodb OWNER TO postgres;

\connect demodb

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 232 (class 1255 OID 32801)
-- Name: check_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_login(iusername character varying, iuserpassword character varying) RETURNS boolean
    LANGUAGE sql
    AS $$
    select exists (select null 
                     from users 
                    where user_name=iusername 
                      and password=iuserpassword
                  ); 
$$;


ALTER FUNCTION public.check_login(iusername character varying, iuserpassword character varying) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 32812)
-- Name: cleanup_slider_data(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cleanup_slider_data(rows_to_keep integer) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN 
	EXECUTE format(
		'DELETE FROM slider_values WHERE id NOT IN (SELECT id FROM slider_values ORDER BY id DESC LIMIT %s)', 
		rows_to_keep
	);
END;
$$;


ALTER FUNCTION public.cleanup_slider_data(rows_to_keep integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 32837)
-- Name: get_slider_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_slider_data() RETURNS TABLE(date_value timestamp with time zone, data_val integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT date_time_field, data_value FROM public.slider_values;
END;
$$;


ALTER FUNCTION public.get_slider_data() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 32842)
-- Name: insert_into_slider_data(timestamp with time zone, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_slider_data(data_time_value timestamp with time zone, data_value integer) RETURNS void
    LANGUAGE plpgsql
    AS $$BEGIN
INSERT INTO public.slider_values(date_time_field, data_value) VALUES (data_time_value, data_value);
EXECUTE public.cleanup_slider_data(5);
END;
$$;


ALTER FUNCTION public.insert_into_slider_data(data_time_value timestamp with time zone, data_value integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 32819)
-- Name: insert_into_slider_data_random(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_into_slider_data_random() RETURNS void
    LANGUAGE sql
    AS $$INSERT INTO public.slider_values(
	date_time_field, value)
	VALUES ( '2024-07-31 10:30:00', FLOOR(RANDOM()*(50 - 10 + 1)) + 10);$$;


ALTER FUNCTION public.insert_into_slider_data_random() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 32803)
-- Name: slider_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slider_values (
    id bigint NOT NULL,
    date_time_field timestamp with time zone NOT NULL,
    data_value integer NOT NULL
);


ALTER TABLE public.slider_values OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 32802)
-- Name: slider_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slider_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slider_values_id_seq OWNER TO postgres;

--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 219
-- Name: slider_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slider_values_id_seq OWNED BY public.slider_values.id;


--
-- TOC entry 217 (class 1259 OID 32769)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_name text NOT NULL,
    password text NOT NULL,
    uid integer NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 32792)
-- Name: users_uid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_uid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_uid_seq OWNER TO postgres;

--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 218
-- Name: users_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_uid_seq OWNED BY public.users.uid;


--
-- TOC entry 3221 (class 2604 OID 32806)
-- Name: slider_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slider_values ALTER COLUMN id SET DEFAULT nextval('public.slider_values_id_seq'::regclass);


--
-- TOC entry 3220 (class 2604 OID 32793)
-- Name: users uid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN uid SET DEFAULT nextval('public.users_uid_seq'::regclass);


--
-- TOC entry 3225 (class 2606 OID 32810)
-- Name: slider_values slider_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slider_values
    ADD CONSTRAINT slider_values_pkey PRIMARY KEY (id);


--
-- TOC entry 3223 (class 2606 OID 32800)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (uid);


-- Completed on 2025-08-01 02:17:12 UTC

--
-- PostgreSQL database dump complete
--

