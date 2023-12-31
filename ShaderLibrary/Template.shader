/*applydfg*/
// Created from amplify template - https://github.com/z3y/ShadersAmplify
Shader /*ase_name*/ "Hidden/Built-In/Lit" /*end*/
{
    Properties
    {
        [HideInInspector] [NonModifiableTextureData] [NoScaleOffset] _DFG ("DFG", 2D) = "black" {}

		/*ase_props*/

		[Toggle(_LTCGI)] _LTCGI ("LTCGI", Float) = 1.0
    }
    SubShader
    {
/*ase_subshader_options:Name=Additional Options
	Option:Surface:Opaque,Transparent:Opaque
		Opaque:SetPropertyOnSubShader:RenderType,Opaque
		Opaque:SetPropertyOnSubShader:RenderQueue,Geometry
		Opaque:SetPropertyOnSubShader:ZWrite,On
		Opaque:HideOption: Blend
		Transparent:SetPropertyOnSubShader:RenderType,Transparent
		Transparent:SetPropertyOnSubShader:RenderQueue,Transparent
		Transparent:SetPropertyOnSubShader:ZWrite,Off
		Transparent:ShowOption: Blend
	Option: Blend:Alpha,Premultiply,Additive,Multiply,Custom:Alpha
		Alpha:SetPropertyOnPass:ForwardBase:BlendRGB,SrcAlpha,OneMinusSrcAlpha
		Alpha:SetPropertyOnPass:ForwardAdd:BlendRGB,SrcAlpha,One
		Alpha:SetDefine:_ALPHAFADE_ON
		Premultiply:SetPropertyOnPass:ForwardBase:BlendRGB,One,OneMinusSrcAlpha
		disable,Premultiply,Additive,Multiply,Custom:SetPropertyOnPass:ForwardAdd:BlendRGB,One,One
		Premultiply:SetDefine:_ALPHAPREMULTIPLY_ON
		Additive:SetPropertyOnPass:ForwardBase:BlendRGB,One,One
		Multiply:SetPropertyOnPass:ForwardBase:BlendRGB,DstColor,Zero
		disable,Premultiply,Additive,Multiply,Custom:RemoveDefine:_ALPHAFADE_ON
		disable,Alpha,Additive,Multiply,Custom:RemoveDefine:_ALPHAPREMULTIPLY_ON
		disable:SetPropertyOnPass:ForwardBase:BlendRGB,One,Zero
	Option:Cutout:true,false:false
		true:SetDefine:_ALPHATEST_ON
		true:SetPropertyOnSubShader:RenderType,TransparentCutout
		true:SetPropertyOnSubShader:RenderQueue,AlphaTest
		false:RemoveDefine:_ALPHATEST_ON
	Option:Bicubic Lightmap:true,false:false
		false:RemoveDefine:_BICUBIC_LIGHTMAP
		true:SetDefine:_BICUBIC_LIGHTMAP
	Option:Mono SH:true,false:false
		false:RemoveDefine:_BAKERY_MONOSH
		true:SetDefine:_BAKERY_MONOSH
	Option:Lightmapped Specular:true,false:false
		true:SetDefine:_LIGHTMAPPED_SPECULAR
		false:RemoveDefine:_LIGHTMAPPED_SPECULAR
	Port:ForwardBase:Normal TS
		On:SetDefine:_NORMALMAP
	Port:ForwardBase:Debug
		On:SetDefine:_DEBUGOUTPUT
		Off:RemoveDefine:_DEBUGOUTPUT
	Option:GSAA:true,false:false
		false:RemoveDefine:_GEOMETRIC_SPECULAR_AA
		true:SetDefine:_GEOMETRIC_SPECULAR_AA
	Option:Vertex Position,InvertActionOnDeselection:Absolute,Relative:Relative
		Absolute:SetDefine:_ABSOLUTE_VERTEX_POS
	Option:Reflections:true,false:true
		false:SetDefine:_GLOSSYREFLECTIONS_OFF
		true:RemoveDefine:_GLOSSYREFLECTIONS_OFF
	Option:Specular:true,false:true
		false:SetDefine:_SPECULARHIGHLIGHTS_OFF
		true:RemoveDefine:_SPECULARHIGHLIGHTS_OFF
	Option:Shading:PBR,Flat:PBR
		PBR:RemoveDefine:_FLATSHADING
		Flat:SetDefine:_FLATSHADING
		Flat:SetDefine:pragma skip_variants SHADOWS_SCREEN
	Option:CBIRP:true,false:false
		true:SetDefine:_CBIRP
		false:RemoveDefine:_CBIRP
	Option:LTCGI:true,false:false
		true:SetDefine:pragma shader_feature_local _LTCGI
		false:RemoveDefine:pragma shader_feature_local _LTCGI
*/
        Tags { "RenderType"="Opaque" "Queue" = "Geometry+0" "DisableBatching" = "False" "LTCGI" = "_LTCGI" }
        Cull Back
		AlphaToMask Off
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		/*ase_stencil*/
		/*ase_all_modules*/

		/*ase_pass*/
        Pass
        {
            /*ase_main_pass*/
            Name "ForwardBase"
            Tags { "LightMode" = "ForwardBase" }
			Blend One Zero

            HLSLPROGRAM
            #pragma target 4.5 
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma skip_variants LIGHTPROBE_SH

            #define pos positionCS
            #define vertex positionOS
            #define normal normalOS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            /*ase_pragma*/

            struct Attributes
            {
                float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                /*ase_vdata:p=p;n=n;t=t;uv0=tc0;uv1=tc1;uv2=tc2*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                #if defined(LIGHTMAP_ON) && defined(DYNAMICLIGHTMAP_ON)
                    centroid float4 lightmapUV : TEXCOORD3;
                #elif defined(LIGHTMAP_ON)
                    centroid float2 lightmapUV : TEXCOORD4;
                #endif
                UNITY_FOG_COORDS(5)
                SHADOW_COORDS(6)
                #if !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    float3 sh : TEXCOORD7;
                #endif
                /*ase_interp(8,):sp=sp;wp=tc0;wn=tc1;wt=tc2*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

            #include "Packages/com.z3y.shadersamplify/ShaderLibrary/Functions.hlsl"
            #ifdef _CBIRP
            #include "Packages/z3y.clusteredbirp/Shaders/CBIRP.hlsl"
            #endif
			#ifdef _LTCGI
				#include "Assets/_pi_/_LTCGI/Shaders/LTCGI.cginc"
			#endif

            /*ase_globals*/
            /*ase_funcs*/

            Varyings vert (Attributes attributes/*ase_vert_input*/)
            {
                Varyings varyings;
				UNITY_SETUP_INSTANCE_ID(attributes);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(varyings);
				UNITY_TRANSFER_INSTANCE_ID(attributes, varyings);

                varyings.positionWS = mul(unity_ObjectToWorld, float4(attributes.positionOS, 1.0)).xyz;
                varyings.normalWS = UnityObjectToWorldNormal(attributes.normalOS);
                varyings.tangentWS  = float4(UnityObjectToWorldDir(attributes.tangentOS.xyz), attributes.tangentOS.w);

                /*ase_vert_code:attributes=Attributes;varyings=Varyings*/
                float3 positionWSOverride = /*ase_vert_out:Vertex Position WS;Float3;_PositionWS*/0.0/*end*/;
				#if !defined(_ABSOLUTE_VERTEX_POS)
					varyings.positionWS += positionWSOverride;
                #else
                    varyings.positionWS = positionWSOverride;
                #endif
				varyings.normalWS = /*ase_vert_out:Vertex Normal WS;Float3;_NormalWS*/varyings.normalWS/*end*/;
				varyings.tangentWS = /*ase_vert_out:Vertex Tangent WS;Float4;_TangentWS*/varyings.tangentWS/*end*/;

                varyings.positionCS = WorldToPositionCS(varyings.positionWS);

                #if defined(LIGHTMAP_ON)
                    varyings.lightmapUV.xy = mad(attributes.uv1.xy, unity_LightmapST.xy, unity_LightmapST.zw);
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                    varyings.lightmapUV.zw = mad(attributes.uv2.xy, unity_DynamicLightmapST.xy, unity_DynamicLightmapST.zw);
                #endif

                #if !UNITY_SAMPLE_FULL_SH_PER_PIXEL
                    varyings.sh = ShadeSHPerVertex(varyings.normalWS, 0);
                #endif

                UNITY_TRANSFER_SHADOW(varyings, attributes.uv1.xy);
                UNITY_TRANSFER_FOG(varyings, varyings.positionCS);
                return varyings;
            }

            half4 frag (Varyings varyings/*ase_frag_input*/) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
                /*ase_local_var*/float2 lightmapUV = 0;
                #if defined(LIGHTMAP_ON)
                    lightmapUV = varyings.lightmapUV;
                #endif
                
                float oddNegativeScale = unity_WorldTransformParams.w;
                float crossSign = (varyings.tangentWS.w > 0.0 ? 1.0 : -1.0) * oddNegativeScale;
                float3 bitangentWS = crossSign * cross(varyings.normalWS.xyz, varyings.tangentWS.xyz);
                float3 tangentWS;
                float3 normalWS;
                /*ase_local_var:wn*/float3 geometricNormalWS = normalize(varyings.normalWS);
                /*ase_local_var:wt*/float3 geometricTangentWS = normalize(varyings.tangentWS.xyz);
                /*ase_local_var:wbt*/float3 geometricBitangentWS = normalize(bitangentWS);
                /*ase_local_var:wp*/float3 positionWS = varyings.positionWS;
                /*ase_local_var:wvd*/float3 viewDirectionWS = normalize(UnityWorldSpaceViewDir(positionWS));
                float3x3 tangentToWorld = float3x3(varyings.tangentWS.xyz, bitangentWS, varyings.normalWS.xyz);
                /*ase_local_var:tvd*/float3 viewDirectionTS = normalize(mul(tangentToWorld, viewDirectionWS));

                Light light = Light::Initialize(varyings);
                /*ase_local_var*/half3 lightColor = light.color;
                /*ase_local_var*/half3 lightDirection = light.direction;
                /*ase_local_var*/half lightAttenuation = light.attenuation;

                /*ase_frag_code:varyings=Varyings*/

                #define ase_tanViewDir viewDirectionTS

                half3 albedo = /*ase_frag_out:Albedo;Float3;_Albedo*/1.0/*end*/;
                float3 normalTS = /*ase_frag_out:Normal TS;Float3;_Normal*/float3(0, 0, 1)/*end*/;
                half3 emission = /*ase_frag_out:Emission;Float3;_Emission*/0.0/*end*/;
                half metallic = /*ase_frag_out:Metallic;Float;_Metallic*/0.0/*end*/;
                half roughness = /*ase_frag_out:Roughness;Float;_Roughness*/0.5/*end*/;
                half reflectance = /*ase_frag_out:Reflectance;Float;_Reflectance*/0.5/*end*/;
                half occlusion = /*ase_frag_out:Occlusion;Float;_Occlusion*/1.0/*end*/;
                half alpha = /*ase_frag_out:Alpha;Float;_Alpha*/1.0/*end*/;
                half alphaClipThreshold = /*ase_frag_out:Alpha Clip Threshold;Float;_AlphaClip*/0.5/*end*/;
                half gsaaVariance = /*ase_frag_out:GSAA Variance;Float;_GSAAV*/0.15/*end*/;
                half gsaaThreshold = /*ase_frag_out:GSAA Threshold;Float;_GSAAT*/0.1/*end*/;
                half specularAOIntensity = /*ase_frag_out:Specular Occlusion;Float;_SPAO*/1.0/*end*/;

                #ifdef _DEBUGOUTPUT
                    half4 debugOutput = /*ase_frag_out:Debug;Float4;_Debug*/0/*end*/;
                    return debugOutput;
                #endif

				ApplyAlphaClip(alpha, alphaClipThreshold);

                #if defined(_NORMALMAP)
                    normalWS = mul(normalTS, tangentToWorld);
                    normalWS = Unity_SafeNormalize(normalWS);
                #else
                    normalWS = geometricNormalWS;
                #endif
                tangentWS = geometricTangentWS;
                bitangentWS = geometricBitangentWS;

                half NoV = abs(dot(normalWS, viewDirectionWS)) + 1e-5f;
                #if defined(_GEOMETRIC_SPECULAR_AA)
                    roughness = Filament::GeometricSpecularAA(geometricNormalWS, roughness, gsaaVariance, gsaaThreshold);
                #endif
                half roughness2 = roughness * roughness;
                half roughness2Clamped = max(roughness2, 0.002);
                float3 reflectVector = reflect(-viewDirectionWS, normalWS);
                #if !defined(QUALITY_LOW)
                    // reflectVector = lerp(reflectVector, normalWS, roughness2);
                #endif
                half3 f0 = 0.16 * reflectance * reflectance * (1.0 - metallic) + albedo * metallic;
                half3 brdf;
                half3 energyCompensation;
                Filament::EnvironmentBRDF(NoV, roughness, f0, brdf, energyCompensation);


                half3 directDiffuse = 0;
                half3 directSpecular = 0;
                half3 indirectSpecular = 0;
                half3 indirectDiffuse = 0;
                half3 indirectOcclusion = 1;
                #if defined(LIGHTMAP_ON)
                    #if defined(_BICUBIC_LIGHTMAP) && !defined(QUALITY_LOW)
                        float4 texelSize = TexelSizeFromTexture2D(unity_Lightmap);
                        half3 illuminance = SampleTexture2DBicubic(unity_Lightmap, custom_bilinear_clamp_sampler, lightmapUV, texelSize, 1.0).rgb;
                    #else
                        half3 illuminance = DecodeLightmap(unity_Lightmap.SampleLevel(custom_bilinear_clamp_sampler, lightmapUV, 0));
                    #endif

                    #if defined(DIRLIGHTMAP_COMBINED) || defined(_BAKERY_MONOSH)
                        #if defined(_BICUBIC_LIGHTMAP) && !defined(QUALITY_LOW)
                            half4 directionalLightmap = SampleTexture2DBicubic(unity_LightmapInd, custom_bilinear_clamp_sampler, lightmapUV, texelSize, 1.0);
                        #else
                            half4 directionalLightmap = unity_LightmapInd.SampleLevel(custom_bilinear_clamp_sampler, lightmapUV, 0);
                        #endif
                        #ifdef _BAKERY_MONOSH
                            half3 L0 = illuminance;
                            half3 nL1 = directionalLightmap * 2.0 - 1.0;
                            half3 L1x = nL1.x * L0 * 2.0;
                            half3 L1y = nL1.y * L0 * 2.0;
                            half3 L1z = nL1.z * L0 * 2.0;
                            half3 sh = L0 + normalWS.x * L1x + normalWS.y * L1y + normalWS.z * L1z;
                            illuminance = sh;
                            #ifdef _LIGHTMAPPED_SPECULAR
                            {
                                half smoothnessLm = 1.0f - roughness2Clamped;
                                smoothnessLm *= sqrt(saturate(length(nL1)));
                                half roughnessLm = 1.0f - smoothnessLm;
                                half3 dominantDir = nL1;
                                half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) + viewDirectionWS);
                                half nh = saturate(dot(normalWS, halfDir));
                                half spec = Filament::D_GGX(nh, roughnessLm);
                                sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
                                
                                #ifdef _ANISOTROPY
                                    // half at = max(roughnessLm * (1.0 + surf.Anisotropy), 0.001);
                                    // half ab = max(roughnessLm * (1.0 - surf.Anisotropy), 0.001);
                                    // indirectSpecular += max(Filament::D_GGX_Anisotropic(nh, halfDir, sd.tangentWS, sd.bitangentWS, at, ab) * sh, 0.0);
                                #else
                                    indirectSpecular += max(spec * sh, 0.0);
                                #endif
                            }
                            #endif
                        #else
                            half halfLambert = dot(normalWS, directionalLightmap.xyz - 0.5) + 0.5;
                            illuminance = illuminance * halfLambert / max(1e-4, directionalLightmap.w);
                        #endif
                    #endif
                    #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                        illuminance = SubtractMainLightWithRealtimeAttenuationFromLightmap(illuminance, light.attenuation, float4(0,0,0,0), normalWS);
                        light = (Light)0;
                    #endif

                    indirectDiffuse = illuminance;

                    #if defined(_BAKERY_MONOSH)
                        indirectOcclusion = (dot(nL1, reflectVector) + 1.0) * L0 * 2.0;
                    #else
                        indirectOcclusion = illuminance;
                    #endif

                #else
					#if defined(_FLATSHADING)
					{
						float3 sh9Dir = (unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
						float3 sh9DirAbs = float3(sh9Dir.x, abs(sh9Dir.y), sh9Dir.z);
						half3 N = normalize(sh9DirAbs);
						UNITY_FLATTEN
						if (!any(unity_SHC.xyz))
						{
							N = 0;
						}
						half3 l0l1 = SHEvalLinearL0L1(float4(N, 1));
						half3 l2 = SHEvalLinearL2(float4(N, 1));
						indirectDiffuse = l0l1 + l2;
					}
					#else
						#if UNITY_SAMPLE_FULL_SH_PER_PIXEL
							indirectDiffuse = ShadeSHPerPixel(normalWS, 0.0, positionWS);
						#else
							indirectDiffuse = ShadeSHPerPixel(normalWS, varyings.sh, positionWS);
						#endif
                    	indirectOcclusion = indirectDiffuse;
					#endif
                #endif
                indirectDiffuse = max(0.0, indirectDiffuse);


                // main light
                ShadeLight(light, viewDirectionWS, normalWS, roughness, NoV, f0, energyCompensation, directDiffuse, directSpecular);

                // reflection probes
                #if !defined(_GLOSSYREFLECTIONS_OFF)
                    Unity_GlossyEnvironmentData envData;
                    envData.roughness = roughness;
                    envData.reflUVW = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);

                    half3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
                    half3 reflectionSpecular = probe0;

                    #if defined(UNITY_SPECCUBE_BLENDING)
                        UNITY_BRANCH
                        if (unity_SpecCube0_BoxMin.w < 0.99999)
                        {
                            envData.reflUVW = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
                            float3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
                            reflectionSpecular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
                        }
                    #endif
                    indirectSpecular += reflectionSpecular;
                #endif

                                
                #ifdef _CBIRP
                     #ifdef LIGHTMAP_ON
                        half4 shadowmask = _Udon_CBIRP_ShadowMask.SampleLevel(custom_bilinear_clamp_sampler, lightmapUV, 0);
                        // half4 shadowmask = 1;
                    #else
                        half4 shadowmask = 1;
                #endif
                    directDiffuse = 0;
                    directSpecular = 0;
                    uint3 cluster = CBIRP::GetCluster(positionWS);
                    CBIRP::ComputeLights(cluster, positionWS, normalWS, viewDirectionWS, f0, NoV, roughness, shadowmask, directDiffuse, directSpecular);
                    directSpecular /= UNITY_PI;
                    directSpecular *= energyCompensation;
                    indirectSpecular = CBIRP::SampleProbes(cluster, reflectVector, positionWS, roughness).xyz;
                #endif

                #if !defined(QUALITY_LOW)
                    float horizon = min(1.0 + dot(reflectVector, normalWS), 1.0);
                    indirectSpecular *= horizon * horizon;
                #endif


				#ifdef _LTCGI
					float2 untransformedLightmapUV = 0;
					#ifdef LIGHTMAP_ON
					untransformedLightmapUV = (lightmapUV - unity_LightmapST.zw) / unity_LightmapST.xy;
					#endif
					float3 ltcgiSpecular = 0;
					float3 ltcgiDiffuse = 0;
					LTCGI_Contribution(positionWS.xyz, normalWS, viewDirectionWS, roughness, untransformedLightmapUV, ltcgiDiffuse, ltcgiSpecular);
					#ifndef LTCGI_DIFFUSE_DISABLED
						directDiffuse += ltcgiDiffuse;
					#endif
					indirectSpecular += ltcgiSpecular;
				#endif

                half3 fr;
                // float surfaceReduction = 1.0 / (roughness2 + 1.0);
                // half grazingTerm = saturate((1.0 - roughness) + (1.0 - metallic));
                // fr = FresnelLerp(f0, grazingTerm, NoV) * surfaceReduction;
                fr = energyCompensation * brdf;
                indirectSpecular *= fr;
                directSpecular *= UNITY_PI;

                half specularAO;
                #if defined(QUALITY_LOW)
                    specularAO = occlusion;
                #else
                    specularAO = Filament::ComputeSpecularAO(NoV, occlusion, roughness2);
                #endif
                directSpecular *= specularAO;
                specularAO *= lerp(1.0, saturate(sqrt(dot(indirectOcclusion + directDiffuse, 1.0))), specularAOIntensity);
                indirectSpecular *= specularAO;

				#ifdef _FLATSHADING
					indirectDiffuse = saturate(max(indirectDiffuse, directDiffuse));
					directDiffuse = 0.0;
				#endif

				AlphaTransparentBlend(alpha, albedo, metallic);

                half4 color = half4(albedo * (1.0 - metallic) * (indirectDiffuse * occlusion + directDiffuse), alpha);
                color.rgb += directSpecular + indirectSpecular;
                color.rgb += emission;

                UNITY_APPLY_FOG(varyings.fogCoord, color);
                return color;
            }
            ENDHLSL
        }
        /*ase_pass*/
        Pass
        {
            /*ase_hide_pass*/
            Name "ForwardAdd"
            Tags { "LightMode" = "ForwardAdd" }
            Fog { Color (0,0,0,0) }
            Blend One One
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5 
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #define pos positionCS
            #define vertex positionOS
            #define normal normalOS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            /*ase_pragma*/

            struct Attributes
            {
                float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                /*ase_vdata:p=p;n=n;t=t*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;
                UNITY_FOG_COORDS(3)
                SHADOW_COORDS(4)
                /*ase_interp(5,):sp=sp;wp=tc0;wn=tc1;wt=tc2*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

            #include "Packages/com.z3y.shadersamplify/ShaderLibrary/Functions.hlsl"

            /*ase_globals*/
            /*ase_funcs*/

            Varyings vert (Attributes attributes/*ase_vert_input*/)
            {
                Varyings varyings;
				UNITY_SETUP_INSTANCE_ID(attributes);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(varyings);
				UNITY_TRANSFER_INSTANCE_ID(attributes, varyings);

                varyings.positionWS = mul(unity_ObjectToWorld, float4(attributes.positionOS, 1.0)).xyz;
                varyings.normalWS = UnityObjectToWorldNormal(attributes.normalOS);
                varyings.tangentWS  = float4(UnityObjectToWorldDir(attributes.tangentOS.xyz), attributes.tangentOS.w);

                /*ase_vert_code:attributes=Attributes;varyings=Varyings*/
                float3 positionWSOverride = /*ase_vert_out:Vertex Position WS;Float3;_PositionWS*/0.0/*end*/;
				#if !defined(_ABSOLUTE_VERTEX_POS)
					varyings.positionWS += positionWSOverride;
                #else
                    varyings.positionWS = positionWSOverride;
                #endif
				varyings.normalWS = /*ase_vert_out:Vertex Normal WS;Float3;_NormalWS*/varyings.normalWS/*end*/;
				varyings.tangentWS = /*ase_vert_out:Vertex Tangent WS;Float4;_TangentWS*/varyings.tangentWS/*end*/;

                varyings.positionCS = WorldToPositionCS(varyings.positionWS);

                UNITY_TRANSFER_SHADOW(varyings, attributes.uv1.xy);
                UNITY_TRANSFER_FOG(varyings, varyings.positionCS);
                return varyings;
            }

            half4 frag (Varyings varyings/*ase_frag_input*/) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
                
                // float renormFactor = 1.0 / length(varyings.normalWS.xyz);
                float oddNegativeScale = unity_WorldTransformParams.w;
                float crossSign = (varyings.tangentWS.w > 0.0 ? 1.0 : -1.0) * oddNegativeScale;
                float3 bitangentWS = crossSign * cross(varyings.normalWS.xyz, varyings.tangentWS.xyz);
                float3 tangentWS;
                float3 normalWS;
                /*ase_local_var:wn*/float3 geometricNormalWS = normalize(varyings.normalWS);
                /*ase_local_var:wt*/float3 geometricTangentWS = normalize(varyings.tangentWS.xyz);
                /*ase_local_var:wbt*/float3 geometricBitangentWS = normalize(bitangentWS);
                /*ase_local_var:wp*/float3 positionWS = varyings.positionWS;
                /*ase_local_var:wvd*/float3 viewDirectionWS = normalize(UnityWorldSpaceViewDir(positionWS));
                float3x3 tangentToWorld = float3x3(varyings.tangentWS.xyz, bitangentWS, varyings.normalWS.xyz);
                /*ase_local_var:tvd*/float3 viewDirectionTS = normalize(mul(tangentToWorld, viewDirectionWS));

                Light light = Light::Initialize(varyings);
                /*ase_local_var*/half3 lightColor = light.color;
                /*ase_local_var*/half3 lightDirection = light.direction;
                /*ase_local_var*/half lightAttenuation = light.attenuation;

                /*ase_frag_code:varyings=Varyings*/

                #define ase_tanViewDir viewDirectionTS

                half3 albedo = /*ase_frag_out:Albedo;Float3;_Albedo*/1.0/*end*/;
                float3 normalTS = /*ase_frag_out:Normal TS;Float3;_Normal*/float3(0, 0, 1)/*end*/;
                half metallic = /*ase_frag_out:Metallic;Float;_Metallic*/0.0/*end*/;
                half roughness = /*ase_frag_out:Roughness;Float;_Roughness*/0.5/*end*/;
                half reflectance = /*ase_frag_out:Reflectance;Float;_Reflectance*/0.5/*end*/;
                half occlusion = /*ase_frag_out:Occlusion;Float;_Occlusion*/1.0/*end*/;
                half alpha = /*ase_frag_out:Alpha;Float;_Alpha*/1.0/*end*/;
                half alphaClipThreshold = /*ase_frag_out:Alpha Clip Threshold;Float;_AlphaClip*/0.5/*end*/;
                half gsaaVariance = /*ase_frag_out:GSAA Variance;Float;_GSAAV*/0.15/*end*/;
                half gsaaThreshold = /*ase_frag_out:GSAA Threshold;Float;_GSAAT*/0.1/*end*/;

                #ifdef _DEBUGOUTPUT
                    half4 debugOutput = /*ase_frag_out:Debug;Float4;_Debug*/0/*end*/;
                    return debugOutput;
                #endif

				ApplyAlphaClip(alpha, alphaClipThreshold);

                #if defined(_NORMALMAP)
                    normalWS = mul(normalTS, tangentToWorld);
                    normalWS = Unity_SafeNormalize(normalWS);
                #else
                    normalWS = geometricNormalWS;
                #endif
                tangentWS = geometricTangentWS;
                bitangentWS = geometricBitangentWS;

                half NoV = abs(dot(normalWS, viewDirectionWS)) + 1e-5f;
                #if defined(_GEOMETRIC_SPECULAR_AA)
                    roughness = Filament::GeometricSpecularAA(geometricNormalWS, roughness, gsaaVariance, gsaaThreshold);
                #endif
                half roughness2 = roughness * roughness;
                half3 f0 = 0.16 * reflectance * reflectance * (1.0 - metallic) + albedo * metallic;
                half3 brdf;
                half3 energyCompensation;
                Filament::EnvironmentBRDF(NoV, roughness, f0, brdf, energyCompensation);

                half3 directDiffuse = 0;
                half3 directSpecular = 0;

                // main light
                ShadeLight(light, viewDirectionWS, normalWS, roughness, NoV, f0, energyCompensation, directDiffuse, directSpecular);
                directSpecular *= UNITY_PI;

                half specularAO;
                #if defined(QUALITY_LOW)
                    specularAO = occlusion;
                #else
                    specularAO = Filament::ComputeSpecularAO(NoV, occlusion, roughness2);
                #endif
                directSpecular *= specularAO;

				#ifdef _FLATSHADING
					directDiffuse = saturate(directDiffuse);
				#endif

				AlphaTransparentBlend(alpha, albedo, metallic);

                half4 color = half4(albedo * (1.0 - metallic) * directDiffuse, alpha);
                color.rgb += directSpecular;

                UNITY_APPLY_FOG(varyings.fogCoord, color);
                return color;
            }
            ENDHLSL
        }
        /*ase_pass*/
        Pass
        {
            /*ase_hide_pass*/
            Name "SHADOWCASTER"
            Tags { "LightMode"="ShadowCaster" }
			AlphaToMask Off
            ZWrite On
            Cull Off
            ZTest LEqual


            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #define pos positionCS
            #define vertex positionOS
            #define normal normalOS
            #include "UnityCG.cginc"
            // #include "Lighting.cginc"
            // #include "AutoLight.cginc"

            /*ase_pragma*/

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                /*ase_vdata:p=p;n=n*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                /*ase_interp(1,):sp=sp*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            
            float4 WorldToShadowCasterPositionCS(float3 positionWS, float3 normalWS)
            {
                if (unity_LightShadowBias.z != 0.0)
                {
                    float3 wLight = normalize(UnityWorldSpaceLightDir(positionWS));

                    // apply normal offset bias (inset position along the normal)
                    // bias needs to be scaled by sine between normal and light direction
                    // (http://the-witness.net/news/2013/09/shadow-mapping-summary-part-1/)
                    //
                    // unity_LightShadowBias.z contains user-specified normal offset amount
                    // scaled by world space texel size.

                    float shadowCos = dot(normalWS, wLight);
                    float shadowSine = sqrt(1-shadowCos*shadowCos);
                    float normalBias = unity_LightShadowBias.z * shadowSine;

                    positionWS -= normalWS * normalBias;
                }

                return mul(UNITY_MATRIX_VP, float4(positionWS, 1.0));
            }

            /*ase_globals*/
            /*ase_funcs*/


            Varyings vert (Attributes attributes/*ase_vert_input*/)
            {
                Varyings varyings;
                UNITY_SETUP_INSTANCE_ID(attributes);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(varyings);
                UNITY_TRANSFER_INSTANCE_ID(attributes, varyings);

                float3 positionWS = mul(unity_ObjectToWorld, float4(attributes.positionOS, 1.0)).xyz;
                float3 normalWS = UnityObjectToWorldNormal(attributes.normalOS);

                /*ase_vert_code:attributes=Attributes;varyings=Varyings*/
                float3 positionWSOverride = /*ase_vert_out:Vertex Position WS;Float3;_PositionWS*/0.0/*end*/;
				#if !defined(_ABSOLUTE_VERTEX_POS)
					positionWS += positionWSOverride;
                #else
                    positionWS = positionWSOverride;
                #endif
				normalWS = /*ase_vert_out:Vertex Normal WS;Float3;_NormalWS*/normalWS/*end*/;

                varyings.positionCS = WorldToShadowCasterPositionCS(positionWS, normalWS);
                varyings.positionCS = UnityApplyLinearShadowBias(varyings.positionCS);
                return varyings;
            }

            void frag (Varyings varyings/*ase_frag_input*/)
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
                /*ase_frag_code:varyings=Varyings*/
                half alpha = /*ase_frag_out:Alpha;Float;_Alpha*/1.0/*end*/;
                half alphaClipThreshold = /*ase_frag_out:Alpha Clip Threshold;Float;_AlphaClip*/0.5/*end*/;
                #ifdef _ALPHATEST_ON
					clip(alpha - alphaClipThreshold);
				#endif
            }
            ENDHLSL
        }
        /*ase_pass*/
        Pass
        {
            /*ase_hide_pass*/
            Name "META"
            Tags { "LightMode"="Meta" }
            Cull Off

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature EDITOR_VISUALIZATION

            #define pos positionCS
            #define vertex positionOS
            #define normal normalOS
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityMetaPass.cginc"
			
            /*ase_pragma*/

            struct Attributes
            {
                float3 positionOS : POSITION;
				float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
                /*ase_vdata:p=p;n=n;t=t;uv0=tc0;uv1=tc1;uv2=tc2*/
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                #ifdef EDITOR_VISUALIZATION
                    float2 vizUV : TEXCOORD0;
                    float4 lightCoord : TEXCOORD1;
                #endif
                /*ase_interp(2,):sp=sp*/
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            /*ase_globals*/
            /*ase_funcs*/

            Varyings vert (Attributes attributes/*ase_vert_input*/)
            {
                Varyings varyings;
                UNITY_SETUP_INSTANCE_ID(attributes);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(varyings);
                UNITY_TRANSFER_INSTANCE_ID(attributes, varyings);
                
                /*ase_vert_code:attributes=Attributes;varyings=Varyings*/

                varyings.positionCS = UnityMetaVertexPosition(float4(attributes.positionOS, 1.0), attributes.uv1.xy, attributes.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);

                #ifdef EDITOR_VISUALIZATION
                    varyings.vizUV = 0;
                    varyings.lightCoord = 0;
                    if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
                        varyings.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, attributes.uv0.xy, attributes.uv1.xy, attributes.uv2.xy, unity_EditorViz_Texture_ST);
                    else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
                    {
                        varyings.vizUV = attributes.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                        varyings.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(attributes.positionOS, 1)));
                    }
                #endif

                return varyings;
            }

            half3 LightmappingAlbedo(half3 diffuse, half3 specular, half roughness)
            {
                half3 res = diffuse;
                res += specular * roughness * 0.5;
                return res;
            }

            half4 frag (Varyings varyings/*ase_frag_input*/) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
                /*ase_frag_code:varyings=Varyings*/
                half3 albedo = /*ase_frag_out:Albedo;Float3;_Albedo*/1.0/*end*/;
                half alpha = /*ase_frag_out:Alpha;Float;_Alpha*/1.0/*end*/;
                half alphaClipThreshold = /*ase_frag_out:Alpha Clip Threshold;Float;_AlphaClip*/0.5/*end*/;
                half roughness = /*ase_frag_out:Roughness;Float;_Roughness*/0.5/*end*/;
                half metallic = /*ase_frag_out:Metallic;Float;_Metallic*/0.0/*end*/;
                half3 emission = /*ase_frag_out:Emission;Float3;_Emission*/0.0/*end*/;

                UnityMetaInput o;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

                half3 specColor;
                half oneMinisReflectivity;
                half3 diffuseColor = DiffuseAndSpecularFromMetallic(albedo, metallic, specColor, oneMinisReflectivity);

                #ifdef EDITOR_VISUALIZATION
                    o.Albedo = diffuseColor;
                    o.VizUV = varyings.vizUV;
                    o.LightCoord = varyings.lightCoord;
                #else
                    o.Albedo = LightmappingAlbedo(diffuseColor, specColor, roughness);
                #endif
                
                o.SpecularColor = specColor;
                o.Emission = emission;

                #if defined(_ALPHATEST_ON)
                    clip(alpha - alphaClipThreshold);
                #endif
                
                return UnityMetaFragment(o);
            }
            ENDHLSL
        }
    }
}
