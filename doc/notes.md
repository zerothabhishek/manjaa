
options:

	safe
	permalink
	


DEFAULTS: 
	
	'safe'		   => false,
	'auto'		   => false,
    'server'       => false,
    'server_port'  => 4000,
	
    'source'       => Dir.pwd,
    'destination'  => File.join(Dir.pwd, '_site'),
    'plugins'      => File.join(Dir.pwd, '_plugins'),
	
    'future'       => true,
    'lsi'          => false,
    'pygments'     => false,
    'markdown'     => 'maruku',
    'permalink'    => 'date',
    
	'maruku'       => {
      'use_tex'    => false,
      'use_divs'   => false,
      'png_engine' => 'blahtex',
      'png_dir'    => 'images/latex',
      'png_url'    => '/images/latex'
    },
    'rdiscount'    => {
      'extensions' => []
    },
    'kramdown'        => {
      'auto_ids'      => true,
      'footnote_nr'   => 1,
      'entity_output' => 'as_char',
      'toc_levels'    => '1..6',
      'use_coderay'   => false,
	
      'coderay' => {
        'coderay_wrap'              => 'div',
        'coderay_line_numbers'      => 'inline',
        'coderay_line_number_start' => 1,
        'coderay_tab_width'         => 4,
        'coderay_bold_every'        => 10,
        'coderay_css'               => 'style'
      }
    }
   