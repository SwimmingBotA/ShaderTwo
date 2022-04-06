// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ariaaaaa/AB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        {
        "Queue"="Transparent"
        "RenderType"="TransparentCutout"
        "ForceNoShadowCasting"="True"
        "IgnoreProjector"="True"
        }
        Pass
        {
          Tags
          {
           "LightMode"="ForwardBase"
          }
          Blend SrcAlpha OneMinusSrcAlpha
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag
          //#pragma multi_compile_fwdbase_fullshadow

          #include "UnityCG.cginc"
          #include "AutoLight.cginc"
          #include "Lighting.cginc"

          sampler2D _MainTex;
          float4 _MainTex_ST;

          struct a2v
          {
              float4 vertex:POSITION;
              float2 uv:TEXCOORD0;
          };

          struct v2f
          {
              float4 pos:SV_POSITION;
              float2 uv:TEXCOORD0;
          };

          v2f vert(a2v v)
          {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv,_MainTex);
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float4 final = tex2D(_MainTex,i.uv);
            return final;
          }
          ENDCG
        }
    }
}
