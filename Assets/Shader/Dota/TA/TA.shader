// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Ariaaaaa/TA"
{
    Properties
    {
      [Header(Texture)]
      _BaseTex("BaseTex",2D)="white"{}
      [Normal]_Bump("BumpTex",2D)="bump"{}
      _Transparency("Transparency",2D)="white"{}
      _DetailMask("DetailMask",2D)="balck"{}
      _CubeMap("CubeMap",Cube)="_Skybox"{}
      _EnvInt("EnvInt",Range(0.0,20.0))=1.0
      _SpePow("SpePow",Range(1.0,30.0))=8.0
      _EmitInt("EmitInt",Range(0.0,20.0))=1.0
      [HDR]_EmitColor("EmitColor",Color)=(1.0,1.0,1.0,1.0)
      [HDR]_TopColor("TopColor",Color)=(1.0,1.0,1.0,1.0)
      [HDR]_SideColor("SideColor",Color)=(1.0,1.0,1.0,1.0)
      [HDR]_DownColor("DownColor",Color)=(1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
                "RenderType"="Opaque"
            }

            Cull Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadow

            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "../../Cginc/EnvColor.cginc"

            //贴图
            sampler2D _BaseTex;
            sampler2D _Bump;
            sampler2D _DetailMask;
            sampler2D _Transparency;
            samplerCUBE _CubeMap;
            //光泽度
            half _EnvInt;
            half _EmitInt;
            half _SpePow;
            half _FresnelPow;
            //环境影响程度


            //颜色
            float4 _EmitColor;
            float4 _TopColor;
            float4 _SideColor;
            float4 _DownColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 worldPos:TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBiTangent : TEXCOORD3;
                float2 uv:TEXCOORD4;
                LIGHTING_COORDS(5,6)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                o.worldTangent = normalize(mul(unity_ObjectToWorld,v.tangent).xyz);
                o.worldBiTangent = normalize(cross(o.worldNormal,o.worldTangent)*v.tangent.w);
                o.uv = v.uv;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                //准备向量
                float3 lDirWS = normalize(UnityWorldSpaceLightDir(i.pos));
                float3 vDirWS = normalize(UnityWorldSpaceViewDir(i.pos));
                float3 nDirTS = UnpackNormal(tex2D(_Bump,i.uv));
                float3x3 TBN = float3x3(i.worldTangent,i.worldBiTangent,i.worldNormal);
                float3 nDirWS = mul(nDirTS,TBN);

                float3 vRefDirWS = reflect(-vDirWS,nDirWS);

                //采样
                float3 baseColor = tex2D(_BaseTex,i.uv);
                float4 maskTex = tex2D(_DetailMask,i.uv);
                float4 transparency = tex2D(_Transparency,i.uv);
                float3 cubeTex = texCUBElod(_CubeMap,float4(vRefDirWS,lerp(8.0,0.0,maskTex.b)));


                //直接光照
                float3 specular = pow(max(0,dot(vRefDirWS,lDirWS)),lerp(1.0,_SpePow,maskTex.g))*transparency.b;
                float3 diffuse = baseColor * (dot(lDirWS,nDirWS)*0.5+0.5);
                float shadow = LIGHT_ATTENUATION(i);

                //间接
                float fresnel = pow(max(0.1,1.0-dot(nDirWS,vDirWS)),maskTex.a);
                float3 envColor = (ThreeColor(nDirWS.g,_TopColor,_SideColor,_DownColor)*baseColor*_EnvInt + cubeTex*fresnel*maskTex.g)*maskTex.r;

                //自发光
                float3 emitColor = _EmitColor * transparency.a * _EmitInt;


                float3 finalColor = (diffuse + specular )*shadow + envColor + emitColor;

                return float4(finalColor,1.0);
            }


            ENDCG
 
        }
    }
    FallBack "Diffuse"
}