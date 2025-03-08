class HackerInteraction extends Interaction;

var HackerGoat myMut;

function InitHackerInteraction(HackerGoat newMut)
{
	myMut=newMut;
}

exec function Login(string username, string password)
{
	if(username == "admin" && password == "secret")
	{
		myMut.BecomeAdmin();
	}
	else if(username == "admin")
	{
		myMut.WorldInfo.Game.Broadcast(myMut, "Wrong password");
	}
	else
	{
		myMut.WorldInfo.Game.Broadcast(myMut, "Wrong username");
	}
}

exec function Logout()
{
	myMut.Disconnect();
}

exec function Geneosis()
{
	myMut.WorldInfo.Game.Broadcast(myMut, "Thanks for playing my mods" @ class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetPlayerNickname(class'Engine'.static.GetEngine().GamePlayers[ 0 ].ControllerId) $ "!");
}