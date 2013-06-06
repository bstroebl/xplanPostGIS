-- -----------------------------------------------------
-- Data for table "QGIS"."layer"
-- -----------------------------------------------------
INSERT INTO "QGIS"."layer" ("schemaname","layername","style")
VALUES ('FP_Bebauung', 'FP_BebauungsFlaeche',
'<qgis version="1.9.0-Master" minimumScale="-4.65661287308e-10" maximumScale="100000000.0" minLabelScale="0" maxLabelScale="1e+08" hasScaleBasedVisibilityFlag="0" scaleBasedLabelVisibilityFlag="0">
 <renderer-v2 attr="allgArtDerBaulNutzung" symbollevels="0" type="categorizedSymbol">
  <categories>
   <category symbol="0" value="" label="keineAngabe"/>
   <category symbol="1" value="1000" label="WohnBauflaeche"/>
   <category symbol="2" value="2000" label="GemischteBauflaeche"/>
   <category symbol="3" value="3000" label="GewerbelicheBauflaeche"/>
   <category symbol="4" value="4000" label="SonderBauflaeche"/>
   <category symbol="5" value="9999" label="SonstigeBauflaeche"/>
  </categories>
  <symbols>
   <symbol alpha="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="191,42,84,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
    <layer pass="0" class="CentroidFill" locked="0">
     <symbol alpha="1" type="marker" name="@0@1">
      <layer pass="0" class="FontMarker" locked="0">
       <prop k="angle" v="0"/>
       <prop k="chr" v="?"/>
       <prop k="color" v="0,0,0,255"/>
       <prop k="font" v="DejaVu Sans"/>
       <prop k="offset" v="0,0"/>
       <prop k="offset_unit" v="MM"/>
       <prop k="size" v="20"/>
       <prop k="size_unit" v="MM"/>
      </layer>
     </symbol>
    </layer>
   </symbol>
   <symbol alpha="1" type="fill" name="1">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="255,138,111,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
   <symbol alpha="1" type="fill" name="2">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="168,112,0,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
   <symbol alpha="1" type="fill" name="3">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="192,192,192,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
   <symbol alpha="1" type="fill" name="4">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="228,92,0,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
   <symbol alpha="1" type="fill" name="5">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="191,42,84,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
  </symbols>
  <source-symbol>
   <symbol alpha="1" type="fill" name="0">
    <layer pass="0" class="SimpleFill" locked="0">
     <prop k="border_width_unit" v="MM"/>
     <prop k="color" v="54,150,105,255"/>
     <prop k="color_border" v="0,0,0,255"/>
     <prop k="offset" v="0,0"/>
     <prop k="offset_unit" v="MM"/>
     <prop k="style" v="solid"/>
     <prop k="style_border" v="solid"/>
     <prop k="width_border" v="0.26"/>
    </layer>
   </symbol>
  </source-symbol>
  <colorramp type="gradient" name="[source]">
   <prop k="color1" v="247,251,255,255"/>
   <prop k="color2" v="8,48,107,255"/>
   <prop k="discrete" v="0"/>
   <prop k="stops" v="0.13;222,235,247,255:0.26;198,219,239,255:0.39;158,202,225,255:0.52;107,174,214,255:0.65;66,146,198,255:0.78;33,113,181,255:0.9;8,81,156,255"/>
  </colorramp>
  <rotation field=""/>
  <sizescale field="" scalemethod="area"/>
 </renderer-v2>
 <customproperties>
  <property key="labeling" value="pal"/>
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
  <property key="labeling/bufferTransp" value="0"/>
  <property key="labeling/centroidWhole" value="false"/>
  <property key="labeling/decimals" value="3"/>
  <property key="labeling/displayAll" value="false"/>
  <property key="labeling/dist" value="0"/>
  <property key="labeling/distInMapUnits" value="false"/>
  <property key="labeling/enabled" value="true"/>
  <property key="labeling/fieldName" value="CASE WHEN  &quot;allgArtDerBaulNutzung&quot; = 1000 THEN ''W'' ||&#xa;  CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1000 THEN ''S'' &#xa;  ELSE&#xa;    CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1100 THEN ''R''&#xa;    ELSE&#xa;      CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1200 THEN ''A''&#xa;      ELSE&#xa;        CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1300 THEN ''B'' &#xa;        ELSE ''''&#xa;        END&#xa;      END&#xa;    END&#xa;  END&#xa;ELSE&#xa;  CASE WHEN  &quot;allgArtDerBaulNutzung&quot; = 2000 THEN ''M'' ||&#xa;    CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1400 THEN ''D'' &#xa;    ELSE&#xa;      CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1500 THEN ''I''&#xa;      ELSE&#xa;        CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1600 THEN ''K''&#xa;        ELSE ''''&#xa;        END&#xa;      END&#xa;    END&#xa;  ELSE&#xa;    CASE WHEN  &quot;allgArtDerBaulNutzung&quot; = 3000 THEN ''G'' ||&#xa;      CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1700 THEN ''E'' &#xa;      ELSE&#xa;        CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 1800 THEN ''I''&#xa;        ELSE ''''&#xa;        END&#xa;      END&#xa;    ELSE&#xa;      CASE WHEN &quot;allgArtDerBaulNutzung&quot; = 4000 THEN&#xa;        CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 2000 THEN ''SOE'' &#xa;        ELSE&#xa;          CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 2100 THEN ''SO''&#xa;          ELSE&#xa;            CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 3000 THEN ''Wochenendhausgebiet''&#xa;            ELSE&#xa;              CASE WHEN &quot;besondereArtDerBaulNutzung&quot; = 4000 THEN ''Sondergebiet'' &#xa;              ELSE ''S''&#xa;              END&#xa;            END&#xa;          END&#xa;        END&#xa;      ELSE&#xa;        CASE WHEN &quot;allgArtDerBaulNutzung&quot; = 9999 THEN ''Sonstige''&#xa;        END&#xa;      END&#xa;    END&#xa;  END&#xa;END&#xa;"/>
  <property key="labeling/fontBold" value="false"/>
  <property key="labeling/fontCapitals" value="0"/>
  <property key="labeling/fontFamily" value="Cantarell"/>
  <property key="labeling/fontItalic" value="false"/>
  <property key="labeling/fontLetterSpacing" value="0"/>
  <property key="labeling/fontLimitPixelSize" value="false"/>
  <property key="labeling/fontMaxPixelSize" value="10000"/>
  <property key="labeling/fontMinPixelSize" value="3"/>
  <property key="labeling/fontSize" value="11"/>
  <property key="labeling/fontSizeInMapUnits" value="false"/>
  <property key="labeling/fontStrikeout" value="false"/>
  <property key="labeling/fontUnderline" value="false"/>
  <property key="labeling/fontWeight" value="50"/>
  <property key="labeling/fontWordSpacing" value="0"/>
  <property key="labeling/formatNumbers" value="false"/>
  <property key="labeling/isExpression" value="true"/>
  <property key="labeling/labelOffsetInMapUnits" value="true"/>
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
  <property key="labeling/namedStyle" value="Regular"/>
  <property key="labeling/obstacle" value="true"/>
  <property key="labeling/placeDirectionSymbol" value="0"/>
  <property key="labeling/placement" value="0"/>
  <property key="labeling/placementFlags" value="0"/>
  <property key="labeling/plussign" value="false"/>
  <property key="labeling/preserveRotation" value="true"/>
  <property key="labeling/previewBkgrdColor" value="#ffffff"/>
  <property key="labeling/priority" value="5"/>
  <property key="labeling/quadOffset" value="4"/>
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
  <property key="labeling/shadowOffsetUnits" value="1"/>
  <property key="labeling/shadowRadius" value="1.5"/>
  <property key="labeling/shadowRadiusAlphaOnly" value="false"/>
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
  <property key="labeling/shapeBorderWidthUnits" value="1"/>
  <property key="labeling/shapeDraw" value="false"/>
  <property key="labeling/shapeFillColorA" value="255"/>
  <property key="labeling/shapeFillColorB" value="255"/>
  <property key="labeling/shapeFillColorG" value="255"/>
  <property key="labeling/shapeFillColorR" value="255"/>
  <property key="labeling/shapeJoinStyle" value="64"/>
  <property key="labeling/shapeOffsetUnits" value="1"/>
  <property key="labeling/shapeOffsetX" value="0"/>
  <property key="labeling/shapeOffsetY" value="0"/>
  <property key="labeling/shapeRadiiUnits" value="1"/>
  <property key="labeling/shapeRadiiX" value="0"/>
  <property key="labeling/shapeRadiiY" value="0"/>
  <property key="labeling/shapeRotation" value="0"/>
  <property key="labeling/shapeRotationType" value="0"/>
  <property key="labeling/shapeSVGFile" value=""/>
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
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerTransparency>0</layerTransparency>
 <displayfield>gid</displayfield>
 <label>0</label>
 <labelattributes>
  <label fieldname="" text="Label"/>
  <family fieldname="" name="Cantarell"/>
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
 <edittypes>
  <edittype editable="1" type="0" name="BMZ"/>
  <edittype editable="1" type="0" name="GFZ"/>
  <edittype editable="1" type="0" name="GFZmax"/>
  <edittype editable="1" type="0" name="GFZmin"/>
  <edittype editable="1" type="0" name="GRZ"/>
  <edittype editable="1" type="3" name="allgArtDerBaulNutzung">
   <valuepair key="GemischteBauflaeche" value="2000"/>
   <valuepair key="GewerblicheBauflaeche" value="3000"/>
   <valuepair key="SonderBauflaeche" value="4000"/>
   <valuepair key="SonstigeBauflaeche" value="9999"/>
   <valuepair key="WohnBauflaeche" value="1000"/>
  </edittype>
  <edittype editable="1" type="0" name="besondereArtDerBaulNutzung"/>
  <edittype editable="1" type="0" name="detaillierteArtDerBaulNutzung"/>
  <edittype editable="1" type="0" name="flaechenschluss"/>
  <edittype editable="1" type="0" name="gid"/>
  <edittype editable="1" type="0" name="nutzungText"/>
  <edittype editable="1" type="0" name="sonderNutzung"/>
 </edittypes>
 <editform></editform>
 <editforminit></editforminit>
 <annotationform></annotationform>
 <editorlayout>generatedlayout</editorlayout>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <attributeactions>
  <actionsetting action="app=QgsApplication.instance();ddManager=app.ddManager;ddManager.showDdForm([% $id %]);" capture="0" type="1" name="showDdForm"/>
 </attributeactions>
</qgis>');
