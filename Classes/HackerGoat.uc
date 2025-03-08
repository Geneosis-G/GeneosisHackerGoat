class HackerGoat extends GGMutator;

var bool isAdmin;
var HackerGoatComponent hgComp;
var Material mAdminMaterial;
var MaterialInterface oldMaterials[4];

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		if(hgComp == none)
		{
			hgComp=HackerGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'HackerGoatComponent', goat.mCachedSlotNr));
			if(hgComp != none)
			{
				InitHackerInteraction();
			}
		}
	}
}

function InitHackerInteraction()
{
	local HackerInteraction hi;

	hi = new class'HackerInteraction';
	hi.InitHackerInteraction(self);
	GetALocalPlayerController().Interactions.AddItem(hi);
}

function BecomeAdmin()
{
	local int slotNr;
	local HackerGoatComponent hacker;
	local GGGoat goat;

	if(isAdmin)
		return;

	WorldInfo.Game.Broadcast(self, "Connected as Administrator");
	isAdmin=true;

	for(slotNr=0 ; slotNr<4 ; ++slotNr)
	{
		hacker=HackerGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'HackerGoatComponent', slotNr));
		if(hacker != none)
		{
			goat=hacker.gMe;
			if(goat.mesh.SkeletalMesh == SkeletalMesh'goat.Mesh.goat')
			{
				oldMaterials[slotNr]=goat.mesh.GetMaterial(0);
				goat.mesh.SetMaterial(0, mAdminMaterial);
			}
		}
	}
}

function Disconnect()
{
	local int slotNr;
	local HackerGoatComponent hacker;
	local GGGoat goat;

	if(!isAdmin)
		return;

	WorldInfo.Game.Broadcast(self, "Disconnected");
	isAdmin=false;

	for(slotNr=0 ; slotNr<4 ; ++slotNr)
	{
		hacker=HackerGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'HackerGoatComponent', slotNr));
		if(hacker != none)
		{
			goat=hacker.gMe;
			if(goat.mesh.GetMaterial(0) == mAdminMaterial)
			{
				goat.mesh.SetMaterial(0, oldMaterials[slotNr]);
				oldMaterials[slotNr]=none;
			}
		}
	}
}

DefaultProperties
{
	mAdminMaterial=Material'Goat_Zombie.Materials.Goat_EarlyAccess_Mat_01'

	mMutatorComponentClass=class'HackerGoatComponent'
}