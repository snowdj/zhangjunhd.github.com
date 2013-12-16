<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" indent="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
	<xsl:variable name="title" select="/rss/channel/title"/>
	<xsl:variable name="feedUrl" select="/rss/channel/atom:link[(@ref)or(@rel)='self']/@href" xmlns:atom="http://www.w3.org/2005/Atom"/>
	<xsl:variable name="selfFeedUrl" select="/rss/channel/fs:self_link/@href" xmlns:fs="http://www.feedsky.com/namespace/feed"/>
	<xsl:variable name="srclink" select="/rss/channel/link"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<title>心内求法</title>
				<link rel="stylesheet" href="/css/ft5.css" type="text/css"/>
				<link rel="alternate" type="application/rss+xml" title="RSS" href="{$feedUrl}"/>
				<xsl:element name="script">
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src">/js/xsl.js</xsl:attribute>
				</xsl:element>
				<xsl:element name="script">
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src">/js/tip.js</xsl:attribute>
				</xsl:element>
				<xsl:element name="script">
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src">/js/download.js</xsl:attribute>
				</xsl:element>
				<xsl:element name="script">
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src">/js/common.js</xsl:attribute>
				</xsl:element>
				<xsl:if test="$srclink">
				<xsl:element name="base">
					<xsl:attribute name="href"><xsl:value-of select="$srclink"/></xsl:attribute>
				</xsl:element>
				</xsl:if>
			</head>
			<xsl:apply-templates select="rss/channel"/>
		</html>
	</xsl:template>

	<xsl:template match="channel">
<body onload="go_decoding();">
<div id="TipLayer" style="visibility:hidden;position:absolute;z-index:1000;top:-100;text-align:left;font-size:12px;"></div>
<div id="header">
	<h1><a href="{link}" style="text-decoration:none;"><xsl:value-of select="$title"/></a></h1>
	<p id="desc"><xsl:value-of select="description" disable-output-escaping="yes"/></p>
</div>
<div id="navigator">
	<ul>
		<li><strong>Feed订阅:</strong>这是一个可以使用RSS阅读器进行订阅的页面，您可以将这个地址添加到您习惯使用的RSS阅读器中。</li>
		<li><strong>在线订阅：</strong>下面列出了常用的几款在线RSS阅读器的快捷订阅图标，您可以直接点击进行订阅。</li>
		<li>
			<a href="http://www.xianguo.com/subscribe.php?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_xianguo.gif" border="0" alt="订阅到鲜果" /></a>
			<a href="http://www.zhuaxia.com/add_channel.php?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_zhuaxia.gif" border="0" alt="订阅到抓虾" /></a>
			<!-- <a href="http://www.pageflakes.com/subscribe.aspx?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_pageflakes.gif" border="0" alt="订阅到飞鸽" /></a> -->
			<a href="http://www.netvibes.com/subscribe.php?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_netvibes.gif" border="0" alt="netvibes" /></a>
			<a href="http://fusion.google.com/add?feedurl={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_google.gif" border="0" alt="google reader" /></a>
			<a href="http://add.my.yahoo.com/rss?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_yahoo.gif" border="0" alt="my yahoo" /></a>
			<a href="http://www.rojo.com/add-subscription?resource={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_rojo.gif" border="0" alt="Rojo" /></a>
			<a href="http://www.newsgator.com/ngs/subscriber/subfext.aspx?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_newsgator.gif" border="0" alt="Newsgator" /></a>
			<a href="http://www.bloglines.com/sub/{$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_bloglines.gif" border="0" alt="bloglines" /></a>
			<a href="http://reader.youdao.com/b.do?keyfrom=feedsky&amp;url={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_youdao.gif" border="0" alt="订阅到有道" /></a>
			<a href="http://mail.qq.com/cgi-bin/feed?u={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_qq.gif" border="0" alt="订阅到QQ邮箱" /></a>
			<a href="http://www.580k.com/myLook/NewStakeOut_Submit.aspx?cm=1&amp;WebUrl={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_580k.gif" border="0" alt="订阅到帮看" /></a>
			<a href="http://yuedu.163.com/instantCustomSub.do?customUrl={$feedUrl}">
				<img src="http://img.feedsky.com/images/icon_subshot02_yuedu163.gif" border="0" alt="订阅到网易云阅读" /></a>
		</li>
		<li>
<script type="text/javascript" language="JavaScript">
function wrapURL(){
	var sp=document.getElementById("feedurl");
	var wrapUrl=sp.getAttribute("value");
	if(wrapUrl==""){
		wrapUrl=sp.getAttribute("value_2");;
	}
	if(wrapUrl.toLowerCase().substring(0,7)=="http://"){
		wrapUrl = wrapUrl.substring(7);
	}
	var arr=new Array();
	arr=wrapUrl.split('/');
	var p="";
	if(arr.length==1){
		p=arr[0];
	}else if(arr.length==2){
		p=arr[1];
	}else{
		p=wrapUrl.substring(wrapUrl.indexOf("/")+1);
	}
	var textNode=document.createTextNode("http://wap.feedsky.com/"+p);
	sp.appendChild(textNode);
	return true;
}
wrapURL();
</script>
		</li>
<!--
<li><span id="wap">
<script language="javascript">
	/*M_CR = 0;
	M_SOURCE = "feedsky";
	write_form();
	fillPhone();
	fillSelect(0);
	document.m_form.m_mobile.options.selectedIndex = 0;
*/
</script>
</span></li>
-->
		<li><strong>离线阅读器：</strong></li>
		<li>
			<a href="javascript:location.href='http://www.potu.com/sub/'+ encodeURI('{$feedUrl}')">
				<img src="http://feeds.feedsky.com/images/potu_01.png" alt="周博通" border="0"/></a>
			<a href="javascript:location.href='http://127.0.0.1:18087/subitem?title=&amp;url='+ encodeURI('{$feedUrl}')" target="_blank">
				<img src="http://feeds.feedsky.com/images/newsants.png" alt="新闻蚂蚁"  border="0"/></a>
			<a href="http://www.esobi.com.cn/esobiweb/index/download.html" target="_blank">
				<img src="http://feeds.feedsky.com/images/esobi.png" alt="易搜比" width="80" height="15" border="0"/></a>
			<br style="clear:both;" />
			
		</li>
		<li><strong>IM提醒：</strong>
			<a href="http://inezha.com/add2?url={$feedUrl}">
				<img src="http://img.feedsky.com/images/addtoanothr4.gif" border="0"  align="middle" alt="Subscribe by Anothr"/></a>
		</li>
	</ul>
</div>
<div id="main">
<div id="content">
	<ul id="item" >
		<xsl:apply-templates select="item"/>
	</ul>
	<div class="clear"><!-- --></div>
</div>
</div>
<script language="javascript" type="text/javascript">
autoSetImgSize("item","98%");
</script>

</body>
	</xsl:template>

	<xsl:template match="item">
		<li class="regularitem">
			<h3><a href="{link}"><xsl:value-of select="title"/></a></h3>
			<span class="date"> <xsl:value-of select="pubDate"/></span>
			<p name="decodeable" class="itemcontent"><xsl:call-template name="outputContent"/></p>
			<xsl:if test="count(child::enclosure)=1">
				<dd>
					<a href="{enclosure/@url}"><img src="http://img.feedsky.com/images/listen.gif" style="vertical-align: middle; padding-left: 4px;"/></a>
				</dd>
			</xsl:if>
		</li>
	</xsl:template>

	<xsl:template match="image">
		<xsl:element name="img" namespace="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="src"><xsl:value-of select="url"/></xsl:attribute>
			<xsl:attribute name="alt">Link to <xsl:value-of select="title"/></xsl:attribute>
			<xsl:attribute name="id">feedimage</xsl:attribute>
		</xsl:element>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="feedsky:browserFriendly" xmlns:feedsky="http://namespace.org/feedsky/ext/1.0">
		<p id="ownerblurb" xmlns="http://www.w3.org/1999/xhtml">
			<em>A message from the feed publisher:</em>
			<xsl:text> </xsl:text>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template name="outputContent">
		<xsl:choose>
			<xsl:when test="xhtml:body" xmlns:xhtml="http://www.w3.org/1999/xhtml">
				<xsl:copy-of select="xhtml:body/*"/>
			</xsl:when>
			<xsl:when test="xhtml:div" xmlns:xhtml="http://www.w3.org/1999/xhtml">
				<xsl:copy-of select="xhtml:div"/>
			</xsl:when>
			<xsl:when test="content:encoded" xmlns:content="http://purl.org/rss/1.0/modules/content/">
				<xsl:value-of select="content:encoded" disable-output-escaping="yes"/>
			</xsl:when>
			<xsl:when test="description">
				<xsl:value-of select="description" disable-output-escaping="yes"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>