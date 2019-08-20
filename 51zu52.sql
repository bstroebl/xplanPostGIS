-- Umstellung von XPlan 5.1 auf 5.2
-- Änderungen in der DB

-- Umstellen des UUID-Generators von Python auf eine in einer Extension enthaltenen Funktion
CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION "XP_Basisobjekte".create_uuid()
  RETURNS character varying AS
$BODY$
BEGIN
    return gen_random_uuid(); -- version 4 uuid
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION "XP_Basisobjekte".create_uuid() TO xp_user;

DROP LANGUAGE plpython2u;

-- vergrössere Felder, damit auch lange Tabellenamen reinpassen
ALTER TABLE "QGIS"."layer" ALTER COLUMN schemaname TYPE character varying (256);
ALTER TABLE "QGIS"."layer" ALTER COLUMN tablename TYPE character varying (256);

-- qv und Stil für BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche
-- -----------------------------------------------------
-- View "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" AS
 SELECT g.gid, g.position,zweckbestimmung
 FROM
 "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" g
 JOIN "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" p ON g.gid = p.gid;
 GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" TO xp_gast;

INSERT INTO "QGIS".layer VALUES (158, 'BP_Verkehr', 'BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche', '<qgis version="2.18.23" simplifyAlgorithm="0" minimumScale="0.0" maximumScale="100000000.0" simplifyDrawingHints="0" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" readOnly="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">
 <edittypes>
  <edittype widgetv2type="TextEdit" name="gid">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
  <edittype widgetv2type="TextEdit" name="zweckbestimmung">
   <widgetv2config IsMultiline="0" fieldEditable="1" constraint="" UseHtml="0" labelOnTop="0" constraintDescription="" notNull="0"/>
  </edittype>
 </edittypes>
 <renderer-v2 forceraster="0" symbollevels="0" type="RuleRenderer" enableorderby="0">
  <rules key="{2c98512e-824f-4618-b8c0-d3abad9d3cac}">
   <rule key="{f2335267-2416-4f38-9b90-d786a1112f95}" symbol="0">
    <rule filter="&quot;zweckbestimmung&quot; = 1000" key="{a0a6d152-c2db-425e-bfdd-6cd129b62b11}" symbol="1" label="Parkplatz"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1100" key="{7aa6aebc-83bb-4c67-9dab-62a965ba0f15}" symbol="2" label="Fussgaengerbereich"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1200" key="{0b3b39d0-2cbb-4cf3-924d-00482fe0652c}" symbol="3" label="VerkehrsberuhigterBereich"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1300" key="{2e7c8e18-26dc-43ac-8600-a7b90daee45f}" symbol="4" label="RadFussweg"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1400" key="{d7257817-191d-462d-b56d-7c2c4915a3bf}" symbol="5" label="Radweg"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1500" key="{2b730508-06b9-4e8c-97a1-f2f35c6da8d6}" symbol="6" label="Fussweg"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1600" key="{a5f41bf8-039f-4ebf-a6e7-3e5bcd5d88e7}" symbol="7" label="FahrradAbstellplatz"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1700" key="{37562a78-8e85-4342-b535-d3335ba49a5d}" symbol="8" label="UeberfuehrenderVerkehrsweg"/>
    <rule filter="&quot;zweckbestimmung&quot; = 1800" key="{4d8f91ec-d2f5-4bd1-b76e-cfa3f8e2048c}" symbol="9" label="UnterfuehrenderVerkehrsweg"/>
   </rule>
  </rules>
  <symbols>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="0">
    <layer pass="0" class="SimpleLine" locked="0">
     <prop k="capstyle" v="square"/>
     <prop k="customdash" v="5;2"/>
     <prop k="customdash_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="customdash_unit" v="MM"/>
     <prop k="draw_inside_polygon" v="0"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="line_color" v="0,0,0,255"/>
     <prop k="line_style" v="solid"/>
     <prop k="line_width" v="0.3"/>
     <prop k="line_width_unit" v="MM"/>
     <prop k="offset" v="0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="use_custom_dash" v="0"/>
     <prop k="width_map_unit_scale" v="0,0,0,0,0,0"/>
    </layer>
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="color" v="255,255,255,255"/>
     <prop k="joinstyle" v="bevel"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_color" v="0,0,0,255"/>
     <prop k="outline_style" v="no"/>
     <prop k="outline_width" v="0.26"/>
     <prop k="outline_width_unit" v="MM"/>
     <prop k="style" v="solid"/>
    </layer>
    <layer pass="0" class="LinePatternFill" locked="0">
     <prop k="angle" v="45"/>
     <prop k="color" v="0,0,255,255"/>
     <prop k="distance" v="6"/>
     <prop k="distance_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="distance_unit" v="MM"/>
     <prop k="line_width" v="0.26"/>
     <prop k="line_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="line_width_unit" v="MM"/>
     <prop k="offset" v="0"/>
     <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
     <prop k="outline_width_unit" v="MM"/>
     <symbol alpha="1" clip_to_extent="1" type="line" name="@0@2">
      <layer pass="0" class="SimpleLine" locked="0">
       <prop k="capstyle" v="square"/>
       <prop k="customdash" v="5;2"/>
       <prop k="customdash_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="customdash_unit" v="MM"/>
       <prop k="draw_inside_polygon" v="0"/>
       <prop k="joinstyle" v="bevel"/>
       <prop k="line_color" v="255,211,85,255"/>
       <prop k="line_style" v="solid"/>
       <prop k="line_width" v="3"/>
       <prop k="line_width_unit" v="MM"/>
       <prop k="offset" v="0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="use_custom_dash" v="0"/>
       <prop k="width_map_unit_scale" v="0,0,0,0,0,0"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="1">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@1@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1000.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="2">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@2@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1100.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="3">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@3@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1200.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="4">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@4@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1300.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="5">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@5@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1400.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="6">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@6@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1500.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="7">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@7@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1600.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="8">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@8@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1700.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" clip_to_extent="1" type="fill" name="9">
    <layer pass="10" class="CentroidFill" locked="0">
     <prop k="point_on_all_parts" v="1"/>
     <prop k="point_on_surface" v="0"/>
     <symbol alpha="1" clip_to_extent="1" type="marker" name="@9@0">
      <layer pass="0" class="SvgMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="horizontal_anchor_point" v="1"/>
       <prop k="name" v="XPlanung_qgis/BP_VerkehrsflaecheBesondererZweckbestimmung_zweckbestimmung_1800.svg"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="outline_color" v="0,0,0,255"/>
       <prop k="outline_width" v="1"/>
       <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="outline_width_unit" v="MM"/>
       <prop k="scale_method" v="diameter"/>
       <prop k="size" v="8"/>
       <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
       <prop k="size_unit" v="MapUnit"/>
       <prop k="vertical_anchor_point" v="1"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
  </symbols>
 </renderer-v2>
 <labeling type="rule-based">
  <rules key="{93661afc-f9f5-4875-8213-8c3831c9705e}">
   <rule description="P_RAnlage" filter="&quot;zweckbestimmung&quot; = 2000" key="{02b2b88a-275c-4e51-a3ed-8f10c63c756c}">
    <settings>
     <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="8.25" fieldName="'P &amp; R'" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
      <substitutions/>
     </text-style>
     <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
     <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
     <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
     <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
     <placement repeatDistanceUnit="1" placement="0" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="10" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
     <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="1" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="0" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
     <data-defined/>
    </settings>
   </rule>
   <rule description="Anschlussflaeche" filter="&quot;zweckbestimmung&quot; = 2200" key="{0941ae38-91d4-4725-be85-b9fb3aa574c5}">
    <settings>
     <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="8.25" fieldName="'Anschlussflaeche'" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
      <substitutions/>
     </text-style>
     <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
     <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
     <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
     <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
     <placement repeatDistanceUnit="1" placement="0" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="10" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
     <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="1" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="0" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
     <data-defined/>
    </settings>
   </rule>
   <rule description="Platz" filter="&quot;zweckbestimmung&quot; = 2100" key="{970252e8-500e-48e4-b184-ffe422e268c1}">
    <settings>
     <text-style fontItalic="0" fontFamily="MS Shell Dlg 2" fontLetterSpacing="0" fontUnderline="0" fontWeight="50" fontStrikeout="0" textTransp="0" previewBkgrdColor="#ffffff" fontCapitals="0" textColor="0,0,0,255" fontSizeInMapUnits="0" isExpression="1" blendMode="0" fontSizeMapUnitScale="0,0,0,0,0,0" fontSize="8.25" fieldName="'Platz'" namedStyle="Normal" fontWordSpacing="0" useSubstitutions="0">
      <substitutions/>
     </text-style>
     <text-format placeDirectionSymbol="0" multilineAlign="0" rightDirectionSymbol=">" multilineHeight="1" plussign="0" addDirectionSymbol="0" leftDirectionSymbol="&lt;" formatNumbers="0" decimals="3" wrapChar="" reverseDirectionSymbol="0"/>
     <text-buffer bufferSize="1" bufferSizeMapUnitScale="0,0,0,0,0,0" bufferColor="255,255,255,255" bufferDraw="0" bufferBlendMode="0" bufferTransp="0" bufferSizeInMapUnits="0" bufferNoFill="0" bufferJoinStyle="64"/>
     <background shapeSizeUnits="1" shapeType="0" shapeSVGFile="" shapeOffsetX="0" shapeOffsetY="0" shapeBlendMode="0" shapeFillColor="255,255,255,255" shapeTransparency="0" shapeSizeMapUnitScale="0,0,0,0,0,0" shapeSizeType="0" shapeJoinStyle="64" shapeDraw="0" shapeBorderWidthUnits="1" shapeSizeX="0" shapeSizeY="0" shapeOffsetMapUnitScale="0,0,0,0,0,0" shapeRadiiX="0" shapeRadiiY="0" shapeOffsetUnits="1" shapeRotation="0" shapeBorderWidth="0" shapeBorderColor="128,128,128,255" shapeRotationType="0" shapeBorderWidthMapUnitScale="0,0,0,0,0,0" shapeRadiiMapUnitScale="0,0,0,0,0,0" shapeRadiiUnits="1"/>
     <shadow shadowOffsetMapUnitScale="0,0,0,0,0,0" shadowOffsetGlobal="1" shadowRadiusUnits="1" shadowTransparency="30" shadowColor="0,0,0,255" shadowUnder="0" shadowScale="100" shadowOffsetDist="1" shadowDraw="0" shadowOffsetAngle="135" shadowRadius="1.5" shadowRadiusMapUnitScale="0,0,0,0,0,0" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOffsetUnits="1"/>
     <placement repeatDistanceUnit="1" placement="0" maxCurvedCharAngleIn="20" repeatDistance="0" distInMapUnits="0" labelOffsetInMapUnits="1" xOffset="0" distMapUnitScale="0,0,0,0,0,0" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" preserveRotation="1" repeatDistanceMapUnitScale="0,0,0,0,0,0" centroidWhole="0" priority="5" yOffset="0" offsetType="0" placementFlags="10" centroidInside="0" dist="0" angleOffset="0" maxCurvedCharAngleOut="-20" fitInPolygonOnly="0" quadOffset="4" labelOffsetMapUnitScale="0,0,0,0,0,0"/>
     <rendering fontMinPixelSize="3" scaleMax="10000000" fontMaxPixelSize="10000" scaleMin="1" upsidedownLabels="0" limitNumLabels="0" obstacle="1" obstacleFactor="1" scaleVisibility="0" fontLimitPixelSize="0" mergeLines="0" obstacleType="0" labelPerPart="0" zIndex="0" maxNumLabels="2000" displayAll="0" minFeatureSize="0"/>
     <data-defined/>
    </settings>
   </rule>
  </rules>
 </labeling>
 <customproperties>
  <property key="embeddedWidgets/count" value="0"/>
  <property key="labeling/addDirectionSymbol" value="false"/>
  <property key="labeling/angleOffset" value="0"/>
  <property key="labeling/blendMode" value="0"/>
  <property key="labeling/bufferBlendMode" value="0"/>
  <property key="labeling/bufferColorA" value="255"/>
  <property key="labeling/bufferColorB" value="255"/>
  <property key="labeling/bufferColorG" value="255"/>
  <property key="labeling/bufferColorR" value="255"/>
  <property key="labeling/bufferDraw" value="false"/>
  <property key="labeling/bufferJoinStyle" value="64"/>
  <property key="labeling/bufferNoFill" value="false"/>
  <property key="labeling/bufferSize" value="1"/>
  <property key="labeling/bufferSizeInMapUnits" value="false"/>
  <property key="labeling/bufferSizeMapUnitMaxScale" value="0"/>
  <property key="labeling/bufferSizeMapUnitMinScale" value="0"/>
  <property key="labeling/bufferSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/bufferTransp" value="0"/>
  <property key="labeling/centroidInside" value="false"/>
  <property key="labeling/centroidWhole" value="false"/>
  <property key="labeling/decimals" value="3"/>
  <property key="labeling/displayAll" value="false"/>
  <property key="labeling/dist" value="0"/>
  <property key="labeling/distInMapUnits" value="false"/>
  <property key="labeling/distMapUnitMaxScale" value="0"/>
  <property key="labeling/distMapUnitMinScale" value="0"/>
  <property key="labeling/distMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/drawLabels" value="false"/>
  <property key="labeling/enabled" value="false"/>
  <property key="labeling/fieldName" value="CASE WHEN  &quot;zweckbestimmung&quot; = 1000 THEN 'P'&#xd;&#xa;ELSE &#xd;&#xa;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1200 THEN 'V'&#xd;&#xa;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1300 THEN 'RF'&#xd;&#xa;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1400 THEN 'R'&#xd;&#xa;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1500 THEN 'FW'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1600 THEN 'AF'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1700 THEN 'Br'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 1800 THEN 'D'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; IN (2000,2200) THEN 'Anschlussflaeche'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;ELSE&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;CASE WHEN  &quot;zweckbestimmung&quot; = 2100 THEN 'Platz'&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;END &#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;&#x9;END&#xd;&#xa;&#x9;&#x9;END&#xd;&#xa;&#x9;END&#xd;&#xa;END "/>
  <property key="labeling/fitInPolygonOnly" value="false"/>
  <property key="labeling/fontBold" value="false"/>
  <property key="labeling/fontCapitals" value="0"/>
  <property key="labeling/fontFamily" value="MS Shell Dlg 2"/>
  <property key="labeling/fontItalic" value="false"/>
  <property key="labeling/fontLetterSpacing" value="0"/>
  <property key="labeling/fontLimitPixelSize" value="false"/>
  <property key="labeling/fontMaxPixelSize" value="10000"/>
  <property key="labeling/fontMinPixelSize" value="3"/>
  <property key="labeling/fontSize" value="8.25"/>
  <property key="labeling/fontSizeInMapUnits" value="false"/>
  <property key="labeling/fontSizeMapUnitMaxScale" value="0"/>
  <property key="labeling/fontSizeMapUnitMinScale" value="0"/>
  <property key="labeling/fontSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/fontStrikeout" value="false"/>
  <property key="labeling/fontUnderline" value="false"/>
  <property key="labeling/fontWeight" value="50"/>
  <property key="labeling/fontWordSpacing" value="0"/>
  <property key="labeling/formatNumbers" value="false"/>
  <property key="labeling/isExpression" value="true"/>
  <property key="labeling/labelOffsetInMapUnits" value="true"/>
  <property key="labeling/labelOffsetMapUnitMaxScale" value="0"/>
  <property key="labeling/labelOffsetMapUnitMinScale" value="0"/>
  <property key="labeling/labelOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/labelPerPart" value="false"/>
  <property key="labeling/leftDirectionSymbol" value="&lt;"/>
  <property key="labeling/limitNumLabels" value="false"/>
  <property key="labeling/maxCurvedCharAngleIn" value="20"/>
  <property key="labeling/maxCurvedCharAngleOut" value="-20"/>
  <property key="labeling/maxNumLabels" value="2000"/>
  <property key="labeling/mergeLines" value="false"/>
  <property key="labeling/minFeatureSize" value="0"/>
  <property key="labeling/multilineAlign" value="0"/>
  <property key="labeling/multilineHeight" value="1"/>
  <property key="labeling/namedStyle" value="Normal"/>
  <property key="labeling/obstacle" value="true"/>
  <property key="labeling/obstacleFactor" value="1"/>
  <property key="labeling/obstacleType" value="0"/>
  <property key="labeling/offsetType" value="0"/>
  <property key="labeling/placeDirectionSymbol" value="0"/>
  <property key="labeling/placement" value="0"/>
  <property key="labeling/placementFlags" value="0"/>
  <property key="labeling/plussign" value="false"/>
  <property key="labeling/predefinedPositionOrder" value="TR,TL,BR,BL,R,L,TSR,BSR"/>
  <property key="labeling/preserveRotation" value="true"/>
  <property key="labeling/previewBkgrdColor" value="#ffffff"/>
  <property key="labeling/priority" value="5"/>
  <property key="labeling/quadOffset" value="4"/>
  <property key="labeling/repeatDistance" value="0"/>
  <property key="labeling/repeatDistanceMapUnitMaxScale" value="0"/>
  <property key="labeling/repeatDistanceMapUnitMinScale" value="0"/>
  <property key="labeling/repeatDistanceMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/repeatDistanceUnit" value="1"/>
  <property key="labeling/reverseDirectionSymbol" value="false"/>
  <property key="labeling/rightDirectionSymbol" value=">"/>
  <property key="labeling/scaleMax" value="10000000"/>
  <property key="labeling/scaleMin" value="1"/>
  <property key="labeling/scaleVisibility" value="false"/>
  <property key="labeling/shadowBlendMode" value="6"/>
  <property key="labeling/shadowColorB" value="0"/>
  <property key="labeling/shadowColorG" value="0"/>
  <property key="labeling/shadowColorR" value="0"/>
  <property key="labeling/shadowDraw" value="false"/>
  <property key="labeling/shadowOffsetAngle" value="135"/>
  <property key="labeling/shadowOffsetDist" value="1"/>
  <property key="labeling/shadowOffsetGlobal" value="true"/>
  <property key="labeling/shadowOffsetMapUnitMaxScale" value="0"/>
  <property key="labeling/shadowOffsetMapUnitMinScale" value="0"/>
  <property key="labeling/shadowOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowOffsetUnits" value="1"/>
  <property key="labeling/shadowRadius" value="1.5"/>
  <property key="labeling/shadowRadiusAlphaOnly" value="false"/>
  <property key="labeling/shadowRadiusMapUnitMaxScale" value="0"/>
  <property key="labeling/shadowRadiusMapUnitMinScale" value="0"/>
  <property key="labeling/shadowRadiusMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shadowRadiusUnits" value="1"/>
  <property key="labeling/shadowScale" value="100"/>
  <property key="labeling/shadowTransparency" value="30"/>
  <property key="labeling/shadowUnder" value="0"/>
  <property key="labeling/shapeBlendMode" value="0"/>
  <property key="labeling/shapeBorderColorA" value="255"/>
  <property key="labeling/shapeBorderColorB" value="128"/>
  <property key="labeling/shapeBorderColorG" value="128"/>
  <property key="labeling/shapeBorderColorR" value="128"/>
  <property key="labeling/shapeBorderWidth" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitMaxScale" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitMinScale" value="0"/>
  <property key="labeling/shapeBorderWidthMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeBorderWidthUnits" value="1"/>
  <property key="labeling/shapeDraw" value="false"/>
  <property key="labeling/shapeFillColorA" value="255"/>
  <property key="labeling/shapeFillColorB" value="255"/>
  <property key="labeling/shapeFillColorG" value="255"/>
  <property key="labeling/shapeFillColorR" value="255"/>
  <property key="labeling/shapeJoinStyle" value="64"/>
  <property key="labeling/shapeOffsetMapUnitMaxScale" value="0"/>
  <property key="labeling/shapeOffsetMapUnitMinScale" value="0"/>
  <property key="labeling/shapeOffsetMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeOffsetUnits" value="1"/>
  <property key="labeling/shapeOffsetX" value="0"/>
  <property key="labeling/shapeOffsetY" value="0"/>
  <property key="labeling/shapeRadiiMapUnitMaxScale" value="0"/>
  <property key="labeling/shapeRadiiMapUnitMinScale" value="0"/>
  <property key="labeling/shapeRadiiMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeRadiiUnits" value="1"/>
  <property key="labeling/shapeRadiiX" value="0"/>
  <property key="labeling/shapeRadiiY" value="0"/>
  <property key="labeling/shapeRotation" value="0"/>
  <property key="labeling/shapeRotationType" value="0"/>
  <property key="labeling/shapeSVGFile" value=""/>
  <property key="labeling/shapeSizeMapUnitMaxScale" value="0"/>
  <property key="labeling/shapeSizeMapUnitMinScale" value="0"/>
  <property key="labeling/shapeSizeMapUnitScale" value="0,0,0,0,0,0"/>
  <property key="labeling/shapeSizeType" value="0"/>
  <property key="labeling/shapeSizeUnits" value="1"/>
  <property key="labeling/shapeSizeX" value="0"/>
  <property key="labeling/shapeSizeY" value="0"/>
  <property key="labeling/shapeTransparency" value="0"/>
  <property key="labeling/shapeType" value="0"/>
  <property key="labeling/textColorA" value="255"/>
  <property key="labeling/textColorB" value="0"/>
  <property key="labeling/textColorG" value="0"/>
  <property key="labeling/textColorR" value="0"/>
  <property key="labeling/textTransp" value="0"/>
  <property key="labeling/upsidedownLabels" value="0"/>
  <property key="labeling/wrapChar" value=""/>
  <property key="labeling/xOffset" value="0"/>
  <property key="labeling/yOffset" value="0"/>
  <property key="labeling/zIndex" value="0"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerTransparency>0</layerTransparency>
 <displayfield>gid</displayfield>
 <label>0</label>
 <labelattributes>
  <label fieldname="" text="Beschriftung"/>
  <family fieldname="" name="MS Shell Dlg 2"/>
  <size fieldname="" units="pt" value="12"/>
  <bold fieldname="" on="0"/>
  <italic fieldname="" on="0"/>
  <underline fieldname="" on="0"/>
  <strikeout fieldname="" on="0"/>
  <color fieldname="" red="0" blue="0" green="0"/>
  <x fieldname=""/>
  <y fieldname=""/>
  <offset x="0" y="0" units="pt" yfieldname="" xfieldname=""/>
  <angle fieldname="" value="0" auto="0"/>
  <alignment fieldname="" value="center"/>
  <buffercolor fieldname="" red="255" blue="255" green="255"/>
  <buffersize fieldname="" units="pt" value="1"/>
  <bufferenabled fieldname="" on=""/>
  <multilineenabled fieldname="" on=""/>
  <selectedonly on=""/>
 </labelattributes>
 <SingleCategoryDiagramRenderer diagramType="Pie" sizeLegend="0" attributeLegend="1">
  <DiagramCategory penColor="#000000" labelPlacementMethod="XHeight" penWidth="0" diagramOrientation="Up" sizeScale="0,0,0,0,0,0" minimumSize="0" barWidth="5" penAlpha="255" maxScaleDenominator="1e+08" backgroundColor="#ffffff" transparency="0" width="15" scaleDependency="Area" backgroundAlpha="255" angleOffset="1440" scaleBasedVisibility="0" enabled="0" height="15" lineSizeScale="0,0,0,0,0,0" sizeType="MM" lineSizeType="MM" minScaleDenominator="inf">
   <fontProperties description="MS Shell Dlg 2,8.25,-1,5,50,0,0,0,0,0" style=""/>
   <attribute field="" color="#000000" label=""/>
  </DiagramCategory>
  <symbol alpha="1" clip_to_extent="1" type="marker" name="sizeSymbol">
   <layer pass="0" class="SimpleMarker" locked="0">
    <prop k="angle" v="0"/>
    <prop k="color" v="255,0,0,255"/>
    <prop k="horizontal_anchor_point" v="1"/>
    <prop k="joinstyle" v="bevel"/>
    <prop k="name" v="circle"/>
    <prop k="offset" v="0,0"/>
    <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="offset_unit" v="MM"/>
    <prop k="outline_color" v="0,0,0,255"/>
    <prop k="outline_style" v="solid"/>
    <prop k="outline_width" v="0"/>
    <prop k="outline_width_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="outline_width_unit" v="MM"/>
    <prop k="scale_method" v="diameter"/>
    <prop k="size" v="2"/>
    <prop k="size_map_unit_scale" v="0,0,0,0,0,0"/>
    <prop k="size_unit" v="MM"/>
    <prop k="vertical_anchor_point" v="1"/>
   </layer>
  </symbol>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings yPosColumn="-1" showColumn="0" linePlacementFlags="10" placement="0" dist="0" xPosColumn="-1" priority="0" obstacle="0" zIndex="0" showAll="1"/>
 <annotationform>.</annotationform>
 <aliases>
  <alias field="gid" index="0" name=""/>
  <alias field="zweckbestimmung" index="1" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <attributeactions default="-1"/>
 <attributetableconfig actionWidgetStyle="dropDown" sortExpression="" sortOrder="0">
  <columns>
   <column width="-1" hidden="0" type="field" name="gid"/>
   <column width="-1" hidden="0" type="field" name="zweckbestimmung"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <editform>.</editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath>.</editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS-Formulare können eine Python-Funktion haben, die beim Öffnen des Formulars gestartet wird.

Hier kann dem Formular Extra-Logik hinzugefügt werden.

Der Name der Funktion wird im Feld "Python-Init-Function" angegeben.
Ein Beispiel:
"""
from PyQt4.QtGui import QWidget

def my_form_open(dialog, layer, feature):
    geom = feature.geometry()
    control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <widgets/>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <defaults>
  <default field="gid" expression=""/>
  <default field="zweckbestimmung" expression=""/>
 </defaults>
 <previewExpression></previewExpression>
</qgis>');

-- vergrößere Feld Beschreibung
DROP VIEW "QGIS"."XP_Bereiche";
DROP VIEW "XP_Basisobjekte"."XP_Bereiche";
DROP VIEW "BP_Basisobjekte"."BP_Plan_qv";
DROP VIEW "XP_Basisobjekte"."XP_Plaene";

ALTER TABLE "XP_Basisobjekte"."XP_Plan"
    ALTER COLUMN beschreibung TYPE text;

CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Plaene" AS
SELECT g.gid, g."raeumlicherGeltungsbereich", name, nummer, "internalId", beschreibung,  kommentar,
  "technHerstellDatum",  "untergangsDatum",  "erstellungsMassstab" ,
  bezugshoehe, CAST(c.relname as varchar) as "Objektart"
FROM  "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" g
JOIN pg_class c ON g.tableoid = c.oid
JOIN "XP_Basisobjekte"."XP_Plan" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Plaene" TO xp_user;
CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich" SET "raeumlicherGeltungsbereich" = new."raeumlicherGeltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Plaene" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_RaeumlicherGeltungsbereich"
  WHERE gid = old.gid;

CREATE  OR REPLACE VIEW "QGIS"."XP_Bereiche" AS
SELECT xb.gid, xb.name as bereichsname, xp.gid as plangid, xp.name as planname, xp."Objektart" as planart,
xp.beschreibung, xp."technHerstellDatum", xp."untergangsDatum"
FROM "XP_Basisobjekte"."XP_Bereich" xb
JOIN (
SELECT gid, "gehoertZuPlan" FROM "FP_Basisobjekte"."FP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "BP_Basisobjekte"."BP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "LP_Basisobjekte"."LP_Bereich"
UNION SELECT gid, "gehoertZuPlan" FROM "SO_Basisobjekte"."SO_Bereich"
) b ON xb.gid = b.gid
JOIN "XP_Basisobjekte"."XP_Plaene" xp ON b."gehoertZuPlan" = xp.gid;
GRANT SELECT ON TABLE "QGIS"."XP_Bereiche" TO xp_gast;
COMMENT ON VIEW "QGIS"."XP_Bereiche" IS 'Zusammenstellung der Pläne mit ihren Bereichen, wenn einzelne
Fachschemas nicht installiert sind, ist der View anzupassen!';

CREATE  OR REPLACE VIEW "XP_Basisobjekte"."XP_Bereiche" AS
SELECT g.gid, COALESCE(g.geltungsbereich, p."raeumlicherGeltungsbereich") as geltungsbereich, b.name, CAST(c.relname as varchar) as "Objektart", p.gid as "planGid", p.name as "planName", p."Objektart" as "planArt"
   FROM "XP_Basisobjekte"."XP_Geltungsbereich" g
   JOIN pg_class c ON g.tableoid = c.oid
   JOIN pg_namespace n ON c.relnamespace = n.oid
   JOIN "XP_Basisobjekte"."XP_Bereich" b ON g.gid = b.gid
   JOIN "XP_Basisobjekte"."XP_Plaene" p ON "XP_Basisobjekte"."gehoertZuPlan"(CAST(n.nspname as varchar), CAST(c.relname as varchar), g.gid) = p.gid;
GRANT SELECT ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_gast;
GRANT ALL ON TABLE "XP_Basisobjekte"."XP_Bereiche" TO xp_user;

CREATE OR REPLACE RULE _update AS
    ON UPDATE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  UPDATE "XP_Basisobjekte"."XP_Geltungsbereich" SET "geltungsbereich" = new."geltungsbereich"
  WHERE gid = old.gid;
CREATE OR REPLACE RULE _delete AS
    ON DELETE TO "XP_Basisobjekte"."XP_Bereiche" DO INSTEAD  DELETE FROM "XP_Basisobjekte"."XP_Geltungsbereich"
  WHERE gid = old.gid;

CREATE OR REPLACE VIEW "BP_Basisobjekte"."BP_Plan_qv" AS
SELECT x.gid, b."raeumlicherGeltungsbereich", x.name, x.nummer, x."internalId", x.beschreibung, x.kommentar,
    x."technHerstellDatum", x."genehmigungsDatum", x."untergangsDatum", x."erstellungsMassstab",
    x.bezugshoehe, b."sonstPlanArt", b.verfahren, b.rechtsstand, b.status, b.hoehenbezug, b."aenderungenBisDatum",
    b."aufstellungsbeschlussDatum", b."veraenderungssperreDatum", b."satzungsbeschlussDatum", b."rechtsverordnungsDatum",
    b."inkrafttretensDatum", b."ausfertigungsDatum", b.veraenderungssperre, b."staedtebaulicherVertrag",
    b."erschliessungsVertrag",  b."durchfuehrungsVertrag", b.gruenordnungsplan
FROM "BP_Basisobjekte"."BP_Plan" b
    JOIN "XP_Basisobjekte"."XP_Plan" x ON b.gid = x.gid;
GRANT SELECT ON TABLE "BP_Basisobjekte"."BP_Plan_qv" TO xp_gast;

-- vergrößere Feld "text"
ALTER TABLE "XP_Basisobjekte"."XP_TextAbschnitt"
    ALTER COLUMN "text" TYPE text;

-- CR 001
INSERT INTO "BP_Bebauung"."BP_Dachform" ("Code", "Bezeichner") VALUES (3000, 'GeneigtesDach');

-- CR 009
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" TO xp_gast;

ALTER TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" ADD COLUMN "nutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_NichtUeberbaubareGrundstuecksflaeche" ADD CONSTRAINT "fk_BP_NichtUeberbaubareGrundstuecksflaeche_nutzung"
    FOREIGN KEY ("nutzung")
    REFERENCES "BP_Bebauung"."BP_NutzungNichUueberbaubGrundstFlaeche" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;

-- CR 010
-- Nacharbeit für BP_UeberbaubareGrundstuecksFlaeche, hätte bereits zu 5.0 geändert werden müssen
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise" DISABLE TRIGGER "change_to_BP_BaugebietBauweise";
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" DROP CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent";
INSERT INTO "BP_Bebauung"."BP_BaugebietBauweise"(gid) SELECT gid FROM "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche";
ALTER TABLE "BP_Bebauung"."BP_UeberbaubareGrundstuecksFlaeche" ADD CONSTRAINT "fk_BP_UeberbaubareGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietBauweise" ENABLE TRIGGER "change_to_BP_BaugebietBauweise";

-- BP_GemeinbedarfsFlaeche
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "bauweise" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "bebauungsArt" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD COLUMN "abweichendeBauweise" INTEGER;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" DISABLE TRIGGER "change_to_BP_GestaltungBaugebiet";
INSERT INTO "BP_Bebauung"."BP_GestaltungBaugebiet"(gid) SELECT gid FROM "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche";
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" DROP CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_parent";
ALTER TABLE "BP_Gemeinbedarf_Spiel_und_Sportanlagen"."BP_GemeinbedarfsFlaeche" ADD CONSTRAINT "fk_BP_GemeinbedarfsFlaeche_parent"
    FOREIGN KEY ("gid" )
    REFERENCES "BP_Bebauung"."BP_GestaltungBaugebiet" ("gid" )
    ON DELETE CASCADE
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_GestaltungBaugebiet" ENABLE TRIGGER "change_to_BP_GestaltungBaugebiet";

-- BP_BesondererNutzungszweckFlaeche
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "bauweise" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "bebauungsArt" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD COLUMN "abweichendeBauweise" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_Bauweise1"
    FOREIGN KEY ("bauweise")
    REFERENCES "BP_Bebauung"."BP_Bauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_AbweichendeBauweise1"
    FOREIGN KEY ("abweichendeBauweise")
    REFERENCES "BP_Bebauung"."BP_AbweichendeBauweise" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche" ADD CONSTRAINT "fk_BP_BesondererNutzungszweckFlaeche_BP_BebauungsArt1"
    FOREIGN KEY ("bebauungsArt")
    REFERENCES "BP_Bebauung"."BP_BebauungsArt" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bauweise" IS 'Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."bebauungsArt" IS 'Detaillierte Festsetzung der Bauweise (§9, Abs. 1, Nr. 2 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BesondererNutzungszweckFlaeche"."abweichendeBauweise" IS 'Nähere Bezeichnung einer "Abweichenden Bauweise" ("bauweise" == 3000).';

-- CR 011
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbweichungVonBaugrenze"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbweichungVonBaugrenze_parent0"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Linienobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" TO bp_user;
CREATE INDEX "BP_AbweichungVonBaugrenze_gidx" ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_AbweichungVonBaugrenze" IS 'Linienhafte Festlegung des Umfangs der Abweichung von der Baugrenze (§23 Abs. 3 Satz 3 BauNVO).';
COMMENT ON COLUMN "BP_Bebauung"."BP_AbweichungVonBaugrenze"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_AbweichungVonBaugrenze" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbweichungVonBaugrenze" AFTER DELETE ON "BP_Bebauung"."BP_AbweichungVonBaugrenze" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" TO bp_user;
CREATE INDEX "BP_AbweichungVonUeberbaubererGrundstuecksFlaeche_gidx" ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" using gist ("position");
COMMENT ON TABLE "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" IS 'Flächenhafte Festlegung des Umfangs der Abweichung von der überbaubaren Grundstücksfläche (§23 Abs. 3 Satz 3 BauNVO).';
COMMENT ON COLUMN "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" AFTER DELETE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_AbweichungVonUeberbaubererGrundstuecksFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- CR 012
-- -----------------------------------------------------
-- Table "BP_Sonstiges"."BP_Sichtflaeche"
-- -----------------------------------------------------
CREATE TABLE "BP_Sonstiges"."BP_Sichtflaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_Sichtflaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Basisobjekte"."BP_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("BP_Basisobjekte"."BP_Flaechenobjekt");

GRANT SELECT ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" TO xp_gast;
GRANT ALL ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" TO bp_user;
CREATE INDEX "BP_Sichtflaeche_gidx" ON "BP_Sonstiges"."BP_Sichtflaeche" using gist ("position");
COMMENT ON TABLE "BP_Sonstiges"."BP_Sichtflaeche" IS 'Flächenhafte Festlegung einer Sichtfläche';
COMMENT ON COLUMN "BP_Sonstiges"."BP_Sichtflaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_BP_Sichtflaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_Sichtflaeche" AFTER DELETE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "ueberlagerung_BP_Sichtflaeche" BEFORE INSERT OR UPDATE ON "BP_Sonstiges"."BP_Sichtflaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isUeberlagerungsobjekt"();

-- CR 013
-- Verschiebe Enumeration BP_Laermpegelbereich nach BP_Umwelt
CREATE TABLE "BP_Umwelt"."BP_Laermpegelbereich" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_Laermpegelbereich" TO xp_gast;
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1000, 'I');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1100, 'II');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1200, 'III');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1300, 'IV');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1400, 'V');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1500, 'VI');
INSERT INTO "BP_Umwelt"."BP_Laermpegelbereich" ("Code", "Bezeichner") VALUES (1600, 'VII');
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" DROP CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1";
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_Laermpegelbereich1"
    FOREIGN KEY ("laermpegelbereich")
    REFERENCES "BP_Umwelt"."BP_Laermpegelbereich" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
-- neue Enumerationen
-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" TO xp_gast;
-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" TO xp_gast;
-- -----------------------------------------------------
-- Table "BP_Umwelt"."BP_ImmissionsschutzTypen"
-- -----------------------------------------------------
CREATE TABLE "BP_Umwelt"."BP_ImmissionsschutzTypen" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "BP_Umwelt"."BP_ImmissionsschutzTypen" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_TechnVorkehrungenImmissionsschutz"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (1000, 'Laermschutzvorkehrung');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10000, 'FassadenMitSchallschutzmassnahmen');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10001, 'Laermschutzwand');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (10002, 'Laermschutzwall');
INSERT INTO "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code", "Bezeichner") VALUES (9999, 'SonstigeVorkehrung');
-- -----------------------------------------------------
-- Data for table "BP_Basisobjekte"."BP_ImmissionsschutzTypen"
-- -----------------------------------------------------
INSERT INTO "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code", "Bezeichner") VALUES (1000, 'Schutzflaeche');
INSERT INTO "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code", "Bezeichner") VALUES (2000, 'BesondereAnlagenVorkehrungen');
-- Tabelle BP_Immissionsschutz um neue Felder ergänzen
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "technVorkehrung" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "detaillierteTechnVorkehrung" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD COLUMN "typ" INTEGER;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_TechnVorkehrungenImmissionsschutz1"
    FOREIGN KEY ("technVorkehrung")
    REFERENCES "BP_Umwelt"."BP_TechnVorkehrungenImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_DetailTechnVorkehrung1"
    FOREIGN KEY ("detaillierteTechnVorkehrung")
    REFERENCES "BP_Umwelt"."BP_DetailTechnVorkehrungImmissionsschutz" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Umwelt"."BP_Immissionsschutz" ADD CONSTRAINT "fk_BP_Immissionsschutz_BP_ImmissionsschutzTypen1"
    FOREIGN KEY ("typ")
    REFERENCES "BP_Umwelt"."BP_ImmissionsschutzTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."technVorkehrung" IS 'Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."detaillierteTechnVorkehrung" IS 'Detaillierte Klassifizierung der auf der Fläche zu treffenden baulichen oder sonstigen technischen Vorkehrungen';
COMMENT ON COLUMN "BP_Umwelt"."BP_Immissionsschutz"."typ" IS 'Differenzierung der Immissionsschutz-Fläche';

-- CR 014
ALTER TABLE "RP_Basisobjekte"."RP_Plan" ADD COLUMN "amtlicherSchluessel" VARCHAR(256);
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."amtlicherSchluessel" IS 'Amtlicher Schlüssel eines Plans auf Basis des AGS-Schlüssels (Amtlicher Gemeindeschlüssel).';

-- CR 015
-- von 4 auf 5.0 wurde RP_Plan um das Attribut verfahren erweitert, dies ist in der DB bisher noch nicht nachvollzogen
-- -----------------------------------------------------
-- Table "RP_Basisobjekte"."RP_Verfahren"
-- -----------------------------------------------------
CREATE TABLE "RP_Basisobjekte"."RP_Verfahren" (
  "Code" INTEGER NOT NULL ,
  "Bezeichner" VARCHAR(64) NOT NULL ,
  PRIMARY KEY ("Code") );
GRANT SELECT ON "RP_Basisobjekte"."RP_Verfahren" TO xp_gast;
-- -----------------------------------------------------
-- Data for table "RP_Basisobjekte"."RP_Verfahren"
-- -----------------------------------------------------
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (1000, 'Aenderung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (2000, 'Teilfortschreibung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (3000, 'Neuaufstellung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (4000, 'Gesamtfortschreibung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (5000, 'Aktualisierung');
INSERT INTO "RP_Basisobjekte"."RP_Verfahren" ("Code", "Bezeichner") VALUES (6000, 'Neubekanntmachung');
-- RP_Plan ändern
ALTER TABLE  "RP_Basisobjekte"."RP_Plan" ADD COLUMN "verfahren" INTEGER;
ALTER TABLE  "RP_Basisobjekte"."RP_Plan" ADD CONSTRAINT "fk_rp_plan_rp_verfahren1"
    FOREIGN KEY ("verfahren" )
    REFERENCES "RP_Basisobjekte"."RP_Verfahren" ("Code" )
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
COMMENT ON COLUMN "RP_Basisobjekte"."RP_Plan"."verfahren" IS 'Verfahrensstatus des Plans.';

-- CR 016
COMMENT ON COLUMN "XP_Praesentationsobjekte"."XP_APObjekt_dientZurDarstellungVon"."index" IS 'Wenn das Attribut art des Fachobjektes mehrfach belegt ist gibt index an, auf welche Instanz des Attributs sich das Präsentationsobjekt bezieht. Indexnummern beginnen dabei immer mit 0.';

-- CR 017
-- BP
ALTER TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" ADD COLUMN "istVerdachtsflaeche" BOOLEAN;
ALTER TABLE "BP_Sonstiges"."BP_KennzeichnungsFlaeche" ADD COLUMN "nummer" CHARACTER VARYING(256);
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."istVerdachtsflaeche" IS 'Legt fest, ob eine Altlast-Verdachtsfläche vorliegt';
COMMENT ON COLUMN "BP_Sonstiges"."BP_KennzeichnungsFlaeche"."nummer" IS 'Nummer im Altlastkataster';
-- FP
ALTER TABLE "FP_Sonstiges"."FP_Kennzeichnung" ADD COLUMN "istVerdachtsflaeche" BOOLEAN;
ALTER TABLE "FP_Sonstiges"."FP_Kennzeichnung" ADD COLUMN "nummer" CHARACTER VARYING(256);
COMMENT ON COLUMN "FP_Sonstiges"."FP_Kennzeichnung"."istVerdachtsflaeche" IS 'Legt fest, ob eine Altlast-Verdachtsfläche vorliegt';
COMMENT ON COLUMN "FP_Sonstiges"."FP_Kennzeichnung"."nummer" IS 'Nummer im Altlastkataster';
-- SO
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bodenschutzrecht"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung bzw. Nummer in einem Altlast-Kataster.';

-- CR 019
-- wird für einen Umbau der Datenstruktur zum Anlass genommen: Entfernen der Klasse BP_BaugebietObjekt und Modellierung des types BP_ZusaetzlicheFestsetzungen
-- -----------------------------------------------------
-- Table "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"
-- -----------------------------------------------------
CREATE TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" (
  "gid" BIGINT NOT NULL,
  "wohnnutzungEGStrasse" INTEGER,
  "ZWohn" INTEGER,
  "GFAntWohnen" INTEGER,
  "GFWohnen" INTEGER,
  "GFAntGewerbe" INTEGER,
  "GFGewerbe" INTEGER,
  "VF" INTEGER,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_BP_ZusaetzlicheFestsetzungen_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_BaugebietBauweise" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_ZusaetzlicheFestsetzungen_BP_Zulaessigkeit"
    FOREIGN KEY ("wohnnutzungEGStrasse")
    REFERENCES "BP_Bebauung"."BP_Zulaessigkeit" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

GRANT SELECT ON TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" TO xp_gast;
GRANT ALL ON TABLE "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" TO bp_user;
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."wohnnutzungEGStrasse" IS 'Festsetzung nach §6a Abs. (4) Nr. 1 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden im Erdgeschoss an der Straßenseite eine Wohnnutzung nicht oder nur ausnahmsweise zulässig ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."ZWohn" IS 'Festsetzung nach §4a Abs. (4) Nr. 1 bzw. nach §6a Abs. (4) Nr. 2 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden oberhalb eines im Bebauungsplan bestimmten Geschosses nur Wohnungen zulässig sind.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFAntWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFWohnen" IS 'Festsetzung nach §4a Abs. (4) Nr. 2 bzw. §6a Abs. (4) Nr. 3 BauNVO: Für besondere Wohngebiete und urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für Wohnungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFAntGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden ein im Bebauungsplan bestimmter Anteil der zulässigen Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."GFGewerbe" IS 'Festsetzung nach §6a Abs. (4) Nr. 4 BauNVO: Für urbane Gebiete oder Teile solcher Gebiete kann festgesetzt werden, dass in Gebäuden eine im Bebauungsplan bestimmte Größe der Geschossfläche für gewerbliche Nutzungen zu verwenden ist.';
COMMENT ON COLUMN "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen"."VF" IS 'Festsetzung der maximal zulässigen Verkaufsfläche in einem Sondergebiet';
-- vorhandene Daten aus BP_BaugebietsTeilFlaeche übernehmen
INSERT INTO "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" ("gid","wohnnutzungEGStrasse","ZWohn","GFAntWohnen","GFWohnen","GFAntGewerbe","GFGewerbe")
SELECT "gid","wohnnutzungEGStrasse","ZWohn","GFAntWohnen","GFWohnen","GFAntGewerbe","GFGewerbe" FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche";
-- jetzt erst Trigger etablieren
CREATE TRIGGER "change_to_BP_ZusaetzlicheFestsetzungen" BEFORE INSERT OR UPDATE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_BP_ZusaetzlicheFestsetzungen" AFTER DELETE ON "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
-- Löschen der vorhandenen Felder in BP_BaugebietsTeilFlaeche
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "wohnnutzungEGStrasse";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "ZWohn";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFAntWohnen";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFWohnen";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFAntGewerbe";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP COLUMN "GFGewerbe";
-- Die Felder aus BP_BaugebietObjekt nach BP_BaugebietsTeilFlaeche
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "allgArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "besondereArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "sondernutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "detaillierteArtDerBaulNutzung" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "nutzungText" VARCHAR(256);
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "abweichungBauNVO" INTEGER;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD COLUMN "zugunstenVon" VARCHAR(64);
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_Baugebiet_XP_AllgArtDerBaulNutzung1"
    FOREIGN KEY ("allgArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_AllgArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1"
    FOREIGN KEY ("besondereArtDerBaulNutzung")
    REFERENCES "XP_Enumerationen"."XP_BesondereArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_Sondernutzungen1"
    FOREIGN KEY ("sondernutzung")
    REFERENCES "XP_Enumerationen"."XP_Sondernutzungen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1"
    FOREIGN KEY ("detaillierteArtDerBaulNutzung")
    REFERENCES "BP_Bebauung"."BP_DetailArtDerBaulNutzung" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1"
    FOREIGN KEY ("abweichungBauNVO")
    REFERENCES "XP_Enumerationen"."XP_AbweichungBauNVOTypen" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE;
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AllgArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("allgArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_BesondereArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("besondereArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_Sondernutzungen1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("sondernutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_BP_DetailArtDerBaulNutzung1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("detaillierteArtDerBaulNutzung");
CREATE INDEX "idx_fk_BP_BaugebietsTF_XP_AbweichungBauNVOTypen1_idx" ON "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ("abweichungBauNVO");
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."allgArtDerBaulNutzung" IS 'Spezifikation der allgemeinen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."besondereArtDerBaulNutzung" IS 'Festsetzung der Art der baulichen Nutzung (§9, Abs. 1, Nr. 1 BauGB).';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."sondernutzung" IS 'Bei Sondergebieten nach BauNVO 1977 oder 1000 (besondereArtDerBaulNutzung == 2000 oder 2100): Spezifische Nutzung der Sonderbaufläche nach §§ 10 und 11 BauNVO.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."detaillierteArtDerBaulNutzung" IS 'Über eine CodeList definierte Nutzungsart.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."nutzungText" IS 'Bei Nutzungsform "Sondergebiet" ("besondereArtDerBaulNutzung" == 2000, 2100, 3000 oder 4000): Kurzform der besonderen Art der baulichen Nutzung.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."abweichungBauNVO" IS 'Art der Abweichung von der BauNVO.';
COMMENT ON COLUMN "BP_Bebauung"."BP_BaugebietsTeilFlaeche"."zugunstenVon" IS 'Angabe des Begünstigen einer Ausweisung.';
-- Daten nach BP_BaugebietsTeilFlaeche übernehmen
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "allgArtDerBaulNutzung" = (SELECT "allgArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "besondereArtDerBaulNutzung" = (SELECT "besondereArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "sondernutzung" = (SELECT "sondernutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "detaillierteArtDerBaulNutzung" = (SELECT "detaillierteArtDerBaulNutzung" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "nutzungText" = (SELECT "nutzungText" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "abweichungBauNVO" = (SELECT "abweichungBauNVO" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
UPDATE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" tf SET "zugunstenVon" = (SELECT "zugunstenVon" FROM "BP_Bebauung"."BP_BaugebietObjekt" o WHERE tf.gid = o.gid);
-- -----------------------------------------------------
-- View "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv"
-- -----------------------------------------------------
DROP VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" AS
SELECT g.*
FROM "BP_Bebauung"."BP_BaugebietsTeilFlaeche" g;
GRANT SELECT ON TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche_qv" TO xp_gast;
-- parent von BP_BaugebietsTeilFlaeche neu ausrichten
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" DROP CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_parent";
ALTER TABLE "BP_Bebauung"."BP_BaugebietsTeilFlaeche" ADD CONSTRAINT "fk_BP_BaugebietsTeilFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "BP_Bebauung"."BP_ZusaetzlicheFestsetzungen" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE;
-- parent von BP_BaugebietObjekt löschen und danach Tabelle löschen
ALTER TABLE "BP_Bebauung"."BP_BaugebietObjekt" DROP CONSTRAINT "fk_BP_Baugebiet_parent";
DROP TABLE "BP_Bebauung"."BP_BaugebietObjekt";

-- CR 020 nicht relevant

-- CR 021
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionBauGBDatum" DATE;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionBauGBText" VARCHAR(255);
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionSonstRechtsgrundlageDatum" DATE;
ALTER TABLE "SO_Basisobjekte"."SO_Plan" ADD COLUMN "versionSonstRechtsgrundlageText" VARCHAR(255);
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionBauGBDatum" IS 'Datum der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionBauGBText" IS 'Textliche Spezifikation der zugrunde liegenden Version des BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionSonstRechtsgrundlageDatum" IS 'Datum einer zugrunde liegenden anderen Rechtsgrundlage als das BauGB.';
COMMENT ON COLUMN "SO_Basisobjekte"."SO_Plan"."versionSonstRechtsgrundlageText" IS 'Textliche Spezifikation einer zugrunde liegenden anderen Rechtsgrundlage als das BauGB.';

-- CR 023 siehe CR 010

-- CR 024
-- BP
-- Tabellen anlegen
-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" (
  "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "zweckbestimmung"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_zweckbestimmung1"
    FOREIGN KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "BP_Verkehr"."BP_ZweckbestimmungStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_zweckbestimmung1" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_zweckbestimmung2" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" IS 'Zweckbestimmung der Fläche';
-- -----------------------------------------------------
-- Table "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" (
  "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung1"
    FOREIGN KEY ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid")
    REFERENCES "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "BP_Verkehr"."BP_DetailZweckbestStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung1" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_BP_VerkehrsFlaecheBZ_detaillierteZweckbestimmung2" ON "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid");
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" TO bp_user;
COMMENT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte zusätzliche Zweckbestimmung der Fläche.';
-- Daten übernehmen
INSERT INTO "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid","zweckbestimmung") SELECT gid,"zweckbestimmung" FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" WHERE "zweckbestimmung" IS NOT NULL;
INSERT INTO "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_detaillierteZweckbestimmung" ("BP_VerkehrsFlaecheBesondererZweckbestimmung_gid","detaillierteZweckbestimmung") SELECT gid,"detaillierteZweckbestimmung" FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" WHERE "detaillierteZweckbestimmung" IS NOT NULL;
-- View ersetzen
DROP VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv";
CREATE OR REPLACE VIEW "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" AS
 SELECT g.gid, g.position, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche" g
 LEFT JOIN
 crosstab('SELECT "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", "BP_VerkehrsFlaecheBesondererZweckbestimmung_gid", zweckbestimmung FROM "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid;
GRANT SELECT ON TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmungFlaeche_qv" TO xp_gast;
-- Felder löschen
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "zweckbestimmung";
ALTER TABLE "BP_Verkehr"."BP_VerkehrsFlaecheBesondererZweckbestimmung" DROP COLUMN "detaillierteZweckbestimmung";
-- FP
-- Tabellen anlegen
-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" (
  "FP_Strassenverkehr_gid" BIGINT NOT NULL,
  "zweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("FP_Strassenverkehr_gid", "zweckbestimmung"),
  CONSTRAINT "fk_FP_Strassenverkehr_zweckbestimmung1"
    FOREIGN KEY ("FP_Strassenverkehr_gid")
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_zweckbestimmung2"
    FOREIGN KEY ("zweckbestimmung")
    REFERENCES "FP_Verkehr"."FP_ZweckbestimmungStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Strassenverkehr_zweckbestimmung1_idx" ON "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("zweckbestimmung");
CREATE INDEX "idx_fk_FP_Strassenverkehr_zweckbestimmung2_idx" ON "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("FP_Strassenverkehr_gid");
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" TO fp_user;
COMMENT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" IS 'Zweckbestimmung der Fläche';
-- -----------------------------------------------------
-- Table "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung"
-- -----------------------------------------------------
CREATE TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" (
  "FP_Strassenverkehr_gid" BIGINT NOT NULL,
  "detaillierteZweckbestimmung" INTEGER NOT NULL,
  PRIMARY KEY ("FP_Strassenverkehr_gid", "detaillierteZweckbestimmung"),
  CONSTRAINT "fk_FP_Strassenverkehr_detaillierteZweckbestimmung1"
    FOREIGN KEY ("FP_Strassenverkehr_gid")
    REFERENCES "FP_Verkehr"."FP_Strassenverkehr" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_FP_Strassenverkehr_detaillierteZweckbestimmung2"
    FOREIGN KEY ("detaillierteZweckbestimmung")
    REFERENCES "FP_Verkehr"."FP_DetailZweckbestStrassenverkehr" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_FP_Strassenverkehr_detaillierteZweckbestimmung1_idx" ON "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("detaillierteZweckbestimmung");
CREATE INDEX "idx_fk_FP_Strassenverkehr_detaillierteZweckbestimmung2_idx" ON "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("FP_Strassenverkehr_gid");
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" TO xp_gast;
GRANT ALL ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" TO fp_user;
COMMENT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" IS 'Über eine CodeList definierte detaillierte Zweckbestimmung der Fläche.';
-- Daten übernehmen
INSERT INTO "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ("FP_Strassenverkehr_gid","zweckbestimmung") SELECT gid,"zweckbestimmung" FROM "FP_Verkehr"."FP_Strassenverkehr" WHERE "zweckbestimmung" IS NOT NULL;
INSERT INTO "FP_Verkehr"."FP_Strassenverkehr_detaillierteZweckbestimmung" ("FP_Strassenverkehr_gid","detaillierteZweckbestimmung") SELECT gid,"detaillierteZweckbestimmung" FROM "FP_Verkehr"."FP_Strassenverkehr" WHERE "detaillierteZweckbestimmung" IS NOT NULL;
-- Views löschen
DROP VIEW IF EXISTS "FP_Verkehr"."FP_Strassenverkehr_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrLinie_qv";
DROP VIEW "FP_Verkehr"."FP_StrassenverkehrPunkt_qv";
-- Views neu anlegen
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_Strassenverkehr_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_Strassenverkehr_qv" AS
 SELECT g.gid, xpo.ebene, xpo.rechtsstand, z1 as zweckbestimmung1,z2 as zweckbestimmung2,z3 as zweckbestimmung3,z4 as zweckbestimmung4,
 coalesce(z1 / z1, 0) + coalesce(z2 / z2, 0) + coalesce(z3 / z3, 0) + coalesce(z4 / z4, 0) as anz_zweckbestimmung
  FROM
 "FP_Verkehr"."FP_Strassenverkehr" g
 LEFT JOIN
 crosstab('SELECT "FP_Strassenverkehr_gid", "FP_Strassenverkehr_gid", zweckbestimmung FROM "FP_Verkehr"."FP_Strassenverkehr_zweckbestimmung" ORDER BY 1,3') zt
 (zgid bigint, z1 integer,z2 integer,z3 integer,z4 integer)
 ON g.gid=zt.zgid
 JOIN "XP_Basisobjekte"."XP_Objekt" xpo ON g.gid = xpo.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_Strassenverkehr_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrFlaeche" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrFlaeche_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrLinie_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrLinie_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrLinie" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrLinie_qv" TO xp_gast;
-- -----------------------------------------------------
-- View "FP_Verkehr"."FP_StrassenverkehrPunkt_qv"
-- -----------------------------------------------------
CREATE OR REPLACE VIEW "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" AS
 SELECT g.gid, g.position, p.ebene, p.rechtsstand, p.zweckbestimmung1, p.zweckbestimmung2, p.zweckbestimmung3, p.zweckbestimmung4, p.anz_zweckbestimmung
FROM "FP_Verkehr"."FP_StrassenverkehrPunkt" g
    JOIN "FP_Verkehr"."FP_Strassenverkehr_qv" p ON g.gid = p.gid;
GRANT SELECT ON TABLE "FP_Verkehr"."FP_StrassenverkehrPunkt_qv" TO xp_gast;
-- Felder löschen
ALTER TABLE "FP_Verkehr"."FP_Strassenverkehr" DROP COLUMN "zweckbestimmung";
ALTER TABLE "FP_Verkehr"."FP_Strassenverkehr" DROP COLUMN "detaillierteZweckbestimmung";

-- CR 025
INSERT INTO "BP_Bebauung"."BP_BebauungsArt" ("Code", "Bezeichner") VALUES (8000, 'EinzelhaeuserDoppelhaeuserHausgruppen');

-- CR 026
-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" TO so_user;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot"
-- -----------------------------------------------------
CREATE TABLE "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" (
  "Code" INTEGER NOT NULL,
  "Bezeichner" VARCHAR(64) NOT NULL,
  PRIMARY KEY ("Code"));

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" TO xp_gast;

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" (
  "gid" BIGINT NOT NULL,
  "artDerFestlegung" INTEGER,
  "detailArtDerFestlegung" INTEGER,
  "rechtlicheGrundlage" INTEGER,
  "name" VARCHAR(64) NULL,
  "nummer" VARCHAR(64) NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_Bauverbotszone_SO_Objekt1"
    FOREIGN KEY ("gid")
    REFERENCES "SO_Basisobjekte"."SO_Objekt" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_artDerFestlegung"
    FOREIGN KEY ("artDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_detailArtDerFestlegung"
    FOREIGN KEY ("detailArtDerFestlegung")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_DetailKlassifizBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT "fk_SO_Bauverbotszone_rechtlicheGrundlage"
    FOREIGN KEY ("rechtlicheGrundlage")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code")
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

CREATE INDEX "idx_fk_SO_Bauverbotszone_artDerFestlegung" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("artDerFestlegung");
CREATE INDEX "idx_fk_SO_Bauverbotszone_detailArtDerFestlegung" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("detailArtDerFestlegung");
CREATE INDEX "idx_fk_SO_Bauverbotszone_rechtlicheGrundlage" ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("rechtlicheGrundlage");
GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" TO so_user;
COMMENT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" IS 'Festlegung nach Bodenschutzrecht.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."artDerFestlegung" IS 'Klassifizierung des Bauverbots bzw. der Baubeschränkung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."detailArtDerFestlegung" IS 'Detaillierte Klassifizierung des Bauverbots bzw. der Baubeschränkung über eine Codeliste';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."rechtlicheGrundlage" IS 'Rechtliche Grundlage des Bauverbots bzw. der Baubeschränkung';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."name" IS 'Informelle Bezeichnung der Festlegung.';
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone"."nummer" IS 'Amtliche Bezeichnung / Kennziffer der Festlegung';
CREATE TRIGGER "change_to_SO_Bauverbotszone" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_Bauverbotszone" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszoneFlaeche_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Flaechenobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszoneFlaeche" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszoneFlaeche" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "SO_BauverbotszoneFlaeche_Flaechenobjekt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneFlaeche" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."isFlaechenobjekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszoneLinie_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Linienobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszoneLinie" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszoneLinie" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszoneLinie" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Table "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt"
-- -----------------------------------------------------
CREATE TABLE  "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" (
  "gid" BIGINT NOT NULL,
  PRIMARY KEY ("gid"),
  CONSTRAINT "fk_SO_BauverbotszonePunkt_parent"
    FOREIGN KEY ("gid")
    REFERENCES "SO_NachrichtlicheUebernahmen"."SO_Bauverbotszone" ("gid")
    ON DELETE CASCADE
    ON UPDATE CASCADE)
INHERITS("SO_Basisobjekte"."SO_Punktobjekt");

GRANT SELECT ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" TO xp_gast;
GRANT ALL ON TABLE "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" TO so_user;
COMMENT ON COLUMN "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt"."gid" IS 'Primärschlüssel, wird automatisch ausgefüllt!';
CREATE TRIGGER "change_to_SO_BauverbotszonePunkt" BEFORE INSERT OR UPDATE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();
CREATE TRIGGER "delete_SO_BauverbotszonePunkt" AFTER DELETE ON "SO_NachrichtlicheUebernahmen"."SO_BauverbotszonePunkt" FOR EACH ROW EXECUTE PROCEDURE "XP_Basisobjekte"."child_of_XP_Objekt"();

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('1000', 'Bauverbotszone');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('2000', 'Baubeschraenkungszone');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('3000', 'Waldabstand');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_KlassifizBauverbot" ("Code", "Bezeichner") VALUES ('9999', 'SonstigeBeschraenkung');

-- -----------------------------------------------------
-- Data for table "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot"
-- -----------------------------------------------------
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('1000', 'Luftverkehrsrecht');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('2000', 'Strassenverkehrsrecht');
INSERT INTO "SO_NachrichtlicheUebernahmen"."SO_RechtlicheGrundlageBauverbot" ("Code", "Bezeichner") VALUES ('9999', 'SonstigesRecht');
-- Deprecated
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachSonstigemRecht" SET "Bezeichner" = 'Bauschutzbereich - künftig wegfallend' WHERE "Code" = 1000;
UPDATE "SO_NachrichtlicheUebernahmen"."SO_KlassifizNachLuftverkehrsrecht" SET "Bezeichner" = 'Baubeschraenkungsbereich - künftig wegfallend' WHERE "Code" = 7000;

-- CR 027
UPDATE "RP_Freiraumstruktur"."RP_ErholungTypen" SET "Bezeichner" = 'LandschaftsbezogeneErholung' WHERE "Code"= 2001;
