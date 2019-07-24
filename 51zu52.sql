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
