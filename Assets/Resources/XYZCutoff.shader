// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/XYZCutoff"
{
    Properties
    {
        _XCutOff("X CutOff", Range(0,1)) = 1 //Interpolate 0 = full cutoff 1 = no cutoff
        _YCutOff("Y CutOff", Range(0,1)) = 1 //Interpolate
        _ZCutOff("Z CutOff", Range(0,1)) = 1 //Interpolate
        _MinCutOff("Min CutOff", Float) = 0 //The X/Y/Z position in worldspace to represent 0% cutoff
        _MaxCutOff("Max CutOff", Float) = 10 //The X/Y/Z position in worldspace to represent 100% cutoff
        _CutOffFadeColor("CutOff Fade Color", Color) = (1,1,1,1)
        [Toggle] _Reverse("Reverse",Float) = 0

        //for section box
        _Enable("Enable", float) = 0
        _MinX("Min X", float) = 0
        _MaxX("Max X", float) = 1
        _MinY("Min Y", float) = 0
        _MaxY("Max Y", float) = 1
        _MinZ("Min Z", float) = 0
        _MaxZ("Max Z", float) = 1

        _Color("Color", Color) = (1,1,1,1)

        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Factor", Range(0.0, 1.0)) = 1.0
        [Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        _SpecColor("Specular", Color) = (0.2,0.2,0.2)
        _SpecGlossMap("Specular", 2D) = "white" {}
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        [Normal] _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        [Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }

    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT SpecularSetup
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 300


        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature_local _PARALLAXMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertBase
            #pragma fragment fragBase

            //#include "UnityStandardCoreForward.cginc"

            //for cutoff animation
            fixed _XCutOff;
            fixed _YCutOff;
            fixed _ZCutOff;
            fixed _MinCutOff;
            fixed _MaxCutOff;
            fixed _CutOffFadeColor;
            fixed _Reverse;

            //for section box
            fixed _MinX;
            fixed _MaxX;
            fixed _MinY;
            fixed _MaxY;
            fixed _MinZ;
            fixed _MaxZ;
            fixed _Enable;
           
            #ifndef UNITY_STANDARD_CORE_FORWARD_INCLUDED
            #define UNITY_STANDARD_CORE_FORWARD_INCLUDED

            #if defined(UNITY_NO_FULL_STANDARD_SHADER)
            #define UNITY_STANDARD_SIMPLE 1
            #endif

            #include "UnityStandardConfig.cginc"

            #undef UNITY_REQUIRE_FRAG_WORLDPOS
            #define UNITY_REQUIRE_FRAG_WORLDPOS 1

            #if UNITY_STANDARD_SIMPLE
            #include "UnityStandardCoreForwardSimple.cginc"
                VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
                half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i);}
            #else
            #include "UnityStandardCore.cginc"
                VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
                #if UNITY_PACK_WORLDPOS_WITH_TANGENT
                half4 fragBase(VertexOutputForwardBase i) : SV_Target
                {
                    float xnormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _XCutOff - (i.tangentToWorldAndPackedData[0].w - _MinCutOff));
                    float xreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _XCutOff) - (_MinCutOff - i.tangentToWorldAndPackedData[0].w));
                    
                    float ynormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _YCutOff - (i.tangentToWorldAndPackedData[1].w - _MinCutOff));
                    float yreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _YCutOff) - (_MinCutOff - i.tangentToWorldAndPackedData[1].w));

                    float znormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _ZCutOff - (i.tangentToWorldAndPackedData[2].w - _MinCutOff));
                    float zreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _ZCutOff) - (_MinCutOff - i.tangentToWorldAndPackedData[2].w));

                    clip((1 - floor(_XCutOff)) * (xnormal + xreverse));
                    clip((1 - floor(_YCutOff)) * (ynormal + yreverse));
                    clip((1 - floor(_ZCutOff)) * (znormal + zreverse));

                    //float x = (i.tangentToWorldAndPackedData[0].w - _MinX) * (_MaxX - i.tangentToWorldAndPackedData[0].w);
                    //float y = (i.tangentToWorldAndPackedData[1].w - _MinY) * (_MaxY - i.tangentToWorldAndPackedData[1].w);
                    //float z = (i.tangentToWorldAndPackedData[2].w - _MinZ) * (_MaxZ - i.tangentToWorldAndPackedData[2].w);

                    //clip(x * _Enable);
                    //clip(y * _Enable);
                    //clip(z * _Enable);

                    return fragForwardBaseInternal(i); 
                }
                #else
                half4 fragBase (VertexOutputForwardBase i) : SV_Target 
                { 
                    float xnormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _XCutOff - (i.posWorld.x - _MinCutOff));
                    float xreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _XCutOff) - (_MinCutOff - i.posWorld.x));

                    float ynormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _YCutOff - (i.posWorld.y - _MinCutOff));
                    float yreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _YCutOff) - (_MinCutOff - i.posWorld.y));

                    float znormal = (1 - _Reverse) * ((_MaxCutOff - _MinCutOff) * _ZCutOff - (i.posWorld.z - _MinCutOff));
                    float zreverse = _Reverse * ((_MinCutOff - _MaxCutOff) * (1 - _ZCutOff) - (_MinCutOff - i.posWorld.z));

                    clip((1 - floor(_XCutOff))* (xnormal + xreverse));
                    clip((1 - floor(_YCutOff))* (ynormal + yreverse));
                    clip((1 - floor(_ZCutOff))* (znormal + zreverse));

                    float x = (i.posWorld.x - _MinX) * (_MaxX - i.posWorld.x);
                    float y = (i.posWorld.y - _MinY) * (_MaxY - i.posWorld.y);
                    float z = (i.posWorld.z - _MinZ) * (_MaxZ - i.posWorld.z);

                    clip(x* _Enable);
                    clip(y* _Enable);
                    clip(z* _Enable);

                    return fragForwardBaseInternal(i); 
                }
                #endif
            #endif
            #endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED    

            ENDCG
        }
        /* Remove additive forward pass

        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature_local _PARALLAXMAP

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        */
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------


            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Deferred pass
        Pass
        {
            Name "DEFERRED"
            Tags { "LightMode" = "Deferred" }

            CGPROGRAM
            #pragma target 3.0
            #pragma exclude_renderers nomrt


            // -------------------------------------

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature_local _PARALLAXMAP

            #pragma multi_compile_prepassfinal
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertDeferred
            #pragma fragment fragDeferred

            #include "UnityStandardCore.cginc"

            ENDCG
        }

        // ------------------------------------------------------------------
        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 150

        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
            #pragma target 2.0

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature_local _DETAIL_MULX2
            // SM2.0: NOT SUPPORTED shader_feature_local _PARALLAXMAP

            #pragma skip_variants SHADOWS_SOFT DYNAMICLIGHTMAP_ON DIRLIGHTMAP_COMBINED

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 2.0

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _DETAIL_MULX2
            // SM2.0: NOT SUPPORTED shader_feature_local _PARALLAXMAP
            #pragma skip_variants SHADOWS_SOFT

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 2.0

            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma skip_variants SHADOWS_SOFT
            #pragma multi_compile_shadowcaster

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        // Extracts information for lightmapping, GI (emission, albedo, ...)
        // This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }

            Cull Off

            CGPROGRAM
            #pragma vertex vert_meta
            #pragma fragment frag_meta

            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _SPECGLOSSMAP
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }

    FallBack "VertexLit"
    //CustomEditor "StandardShaderGUI"
    CustomEditor "XYZCuttoffGUI"
}