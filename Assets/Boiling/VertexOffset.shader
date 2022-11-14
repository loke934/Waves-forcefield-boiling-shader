Shader "Unlit/VertexOffset"
{
    Properties
    {
        _ColorA("ColorA", Color) =(1,1,1,1)
        _ColorB("ColorB", Color) =(1,1,1,1)
        _Amplitude ("Amplitude", Range(0,0.5)) = 0.3
    }

    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define TAU 6.28318530718
            
            float4 _ColorA;
            float4 _ColorB;
            float _Amplitude;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float4 uv0 : TEXCOORD0;
               
            };

            struct Interpolators 
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 -1;
                float radialDistance = length(uvCentered);
                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5);
                wave *= 1- radialDistance;
                return wave;
            }
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.y = GetWave(v.uv0) * _Amplitude;
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.normal = UnityObjectToWorldNormal(v.normals); 
                o.uv = v.uv0;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float4 gradient = lerp(_ColorA, _ColorB, GetWave(i.uv));
                return gradient;
            }
            ENDCG
        }
    }
}
