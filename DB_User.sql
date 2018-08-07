-- -----------------------------------------------------
-- Anlegen der Nutzergruppen für die Fachschemas
-- Jedes Fachschema hat eine eigene Nutzergruppe, der dann die entsprechenden Nutzerrollebn
-- zugewiesen werden können.
-- Dieses Skript ist nur einmalig pro Server auszuführen, da die Rollen
-- nicht datenbankspezifisch sind!
-- -----------------------------------------------------

/* *************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ************************************************************************* */

-- *****************************************************
-- CREATE GROUP ROLES
-- *****************************************************

-- Lesende Rolle
CREATE ROLE xp_gast
  NOSUPERUSER NOINHERIT NOCREATEDB NOCREATEROLE;

-- allgemein editierende Rolle, spezielle editierende Rollen werden im folgenden erzeugt
CREATE ROLE xp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_gast TO xp_user;

-- editierende Rolle für BP_Fachschema_BPlan
CREATE ROLE bp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO bp_user;

-- editierende Rolle für FP_Fachschema_FPlan
CREATE ROLE fp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO fp_user;

-- editierende Rolle für LP_Fachschema_LPlan
CREATE ROLE lp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO lp_user;

-- editierende Rolle für RP_Fachschema_RPlan
CREATE ROLE rp_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO rp_user;

-- editierende Rolle für SO_SonstigePlanwerke
CREATE ROLE so_user
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
GRANT xp_user TO so_user;