Shader "Ariaaaaa/Scale"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Opacity("Opacity",Range(0.0,1.0))=1.0
        _ScaleRange("MoveRange",Range(0.0,3.0))=1.0
        _ScaleSpeed("MoveSpeed",float)=1.0
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
          Blend One OneMinusSrcAlpha
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag
          //#pragma multi_compile_fwdbase_fullshadow

          #include "UnityCG.cginc"
          #include "AutoLight.cginc"
          #include "Lighting.cginc"

          sampler2D _MainTex;

          half _Opacity;
          half _ScaleRange;
          float  _ScaleSpeed;

          #define TWO_PI 6.283185

          void Scale(inout float3 vertex)
          {
                vertex.xyz = vertex.xyz*(1.0+_ScaleRange * sin(frac(_Time.z * _ScaleSpeed)*TWO_PI));
          }

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
            Scale(v.vertex.xyz);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            return o;
          }

          float4 frag(v2f i):SV_Target
          {
            float4 mainTex = tex2D(_MainTex,i.uv);

            float3 finalColor = mainTex.rgb;

            float opacity = mainTex.a * _Opacity;


            return float4(finalColor * opacity,opacity);
          }
          ENDCG
        }
    }
}
