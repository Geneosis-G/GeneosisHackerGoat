class HackerGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var StaticMeshComponent phoneMesh;
var SoundCue hackSound;
var SoundCue glitchSound;
var float hackRadius;

var array<string> availableViewModes;
var int currentViewMode;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		phoneMesh.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponentToSocket( phoneMesh, 'hairSocket' );
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	if(PCOwner != gMe.Controller)
		return;

	if( keyState == KS_Down )
	{
		if(newKey == 'LEFTCONTROL' || newKey == 'XboxTypeS_DPad_Down')
		{
			gMe.SetTimer(2.f, false, NameOf(HackGraphics), self);
		}

		if(newKey == 'T' || newKey == 'XboxTypeS_LeftThumbStick')
		{
			GlitchThemAll();
		}
	}
	else if( keyState == KS_Up )
	{
		if(newKey == 'LEFTCONTROL' || newKey == 'XboxTypeS_DPad_Down')
		{
			if(gMe.IsTimerActive(NameOf(HackGraphics), self))
			{
				gMe.ClearTimer(NameOf(HackGraphics), self);
			}
		}
	}
}

function HackGraphics()
{
	if(gMe.Controller == none)
		return;

	currentViewMode++;
	if(currentViewMode == availableViewModes.Length)
	{
		currentViewMode=0;
	}
	gMe.PlaySound(hackSound);
	PlayerController(gMe.Controller).ConsoleCommand("viewmode" @ availableViewModes[currentViewMode]);
	gMe.SetTimer(2.f, false, NameOf(HackGraphics), self);
}

function GlitchThemAll()
{
	local Actor actorToGlitch;
	local GGPawn pawnToGlitch;
	local GGKActor kActorToGlitch;
	local GGInterpActor interpActorToGlitch;
	local GGSVehicle vehicleToGlitch;
	local vector newDrawScale3D;
	local float newGravity;

	gMe.PlaySound(glitchSound);

	foreach myMut.CollidingActors(class'Actor', actorToGlitch, hackRadius, gMe.Location,,)
	{
		pawnToGlitch=GGPawn(actorToGlitch);
		kActorToGlitch=GGKActor(actorToGlitch);
		interpActorToGlitch=GGInterpActor(actorToGlitch);
		vehicleToGlitch=GGSVehicle(actorToGlitch);

		if(actorToGlitch == gMe)
		{
			//myMut.WorldInfo.Game.Broadcast(myMut, "ignored:" $ actorToGlitch);
			continue;
		}

		if(actorToGlitch.bWorldGeometry && !HackerGoat(myMut).isAdmin)
		{
			continue;
		}

		//Glitch scale
		if(pawnToGlitch == none)
		{
			newDrawScale3D=GetRandomVector();
			actorToGlitch.SetDrawScale3D(newDrawScale3D);
		}

		//Glitch speed
		actorToGlitch.CustomTimeDilation=GetRandomFloat();

		//Glitch gravity
		newGravity=GetRandomFloat();

		if(pawnToGlitch != none)
		{
			pawnToGlitch.CustomGravityScaling=newGravity;
			GlitchPawn(pawnToGlitch);
		}
		else if(kActorToGlitch != none)
		{
			kActorToGlitch.StaticMeshComponent.BodyInstance.CustomGravityFactor=newGravity;
		}
		else if(interpActorToGlitch != none)
		{
			interpActorToGlitch.StaticMeshComponent.BodyInstance.CustomGravityFactor=newGravity;
		}
		else if(vehicleToGlitch != none)
		{
			vehicleToGlitch.Mesh.BodyInstance.CustomGravityFactor=newGravity;
		}
	}
}

function GlitchPawn(GGPawn pawnToGlitch)
{
	local array<name> boneNames;
	local name boneName;
	local SkelControlBase skelControl;

	pawnToGlitch.mesh.GetBoneNames(boneNames);
	foreach boneNames(boneName)
	{
		skelControl = pawnToGlitch.mesh.FindSkelControl( boneName );
		if( skelControl == none )
		{
			if( pawnToGlitch.Mesh.MatchRefBone( boneName ) != INDEX_NONE )
			{
				skelControl = pawnToGlitch.Mesh.AddSkelControl( boneName, class'SkelControlSingleBone' );
				skelControl.ControlName = boneName;
			}
		}

		if( skelControl != none )
		{
			skelControl.BoneScale = GetRandomFloat();

			skelControl.SetSkelControlStrength( 0.0f, 0.0f );
			skelControl.SetSkelControlStrength( 1.0f, 1.0f );
		}
	}
}

//Generate a random vector of values between 0.5 and 2
function vector GetRandomVector()
{
	local vector v;

	v.X=GetRandomFloat();
	v.Y=GetRandomFloat();
	v.Z=GetRandomFloat();

	return v;
}

//Generate a random number between 0.5 and 2
function float GetRandomFloat()
{
	local float randNum;

	randNum=RandRange(-1.f, 1.f);
	if(randNum >= 0.f)
	{
		return (randNum+1.f);
	}
	else
	{
		return (1.f/(-randNum+1.f));
	}
}

defaultproperties
{
	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Props_01.Mesh.Stereo_Display_01'
		Rotation=(Pitch=0, Yaw=4000, Roll=4000)
		Translation=(X=-20.f, Y=40.f, Z=-20.f)
		Scale3D=(X=0.5f, Y=-0.5f, Z=0.8f)
	End Object
	phoneMesh=StaticMeshComp1

	hackSound=SoundCue'MMO_SFX_SOUND.Cue.SFX_Genie_Spells_Spawn_Cue'
	glitchSound=SoundCue'MMO_SFX_SOUND.Cue.NPC_Ninja_Submit_Goat_Launch_Cue'

	hackRadius=1000.f

	currentViewMode
	availableViewModes.Add("lit")
	availableViewModes.Add("unlit")
	availableViewModes.Add("litlightmapdensity")
	availableViewModes.Add("lightingonly")
	availableViewModes.Add("wireframe")
}