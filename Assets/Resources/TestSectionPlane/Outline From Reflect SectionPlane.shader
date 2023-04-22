// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Inspired from http://wiki.unity3d.com/index.php/Silhouette-Outlined_Diffuse

Shader "Effects/Outline2"
{
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)

		_Enable("Enable", float) = 0
        _X("X", float) = 0
        _Y("Y", float) = 1
        _Z("Z", float) = 0
        _XC("XC", float) = 0
        _YC("YC", float) = 0
        _ZC("ZC", float) = 0

	}

	CGINCLUDE
	#include "UnityCG.cginc"
 
	struct appdata {
		float4 vertex : POSITION;
	};
 
	struct v2f {
		float4 pos : POSITION;
		float3 worldPos : TEXCOORD0;
		float4 color : COLOR;
	};

	uniform float4 _Color;
	v2f vert(appdata v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldPos = mul (unity_ObjectToWorld, v.vertex);
		o.color = _Color;
		return o;
	}
	ENDCG

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Pass {
			Name "BASE"
			ZWrite On
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			Lighting On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed _X;
			fixed _Y;
			fixed _Z;
			fixed _XC;
			fixed _YC;
			fixed _ZC;
			fixed _Enable;
 
			half4 frag(v2f i) : COLOR 
			{
				//float x = (i.worldPos.x - _MinX) * (_MaxX - i.worldPos.x);
				//float y = (i.worldPos.y - _MinY) * (_MaxY - i.worldPos.y);
				//float z = (i.worldPos.z - _MinZ) * (_MaxZ - i.worldPos.z);

				clip(_X * (i.worldPos.x - _XC) + _Y * (i.worldPos.y - _YC) + _Z * (i.worldPos.z - _ZC));

				return i.color;
			}
			ENDCG
		}
	}
 
	Fallback "Diffuse"
}